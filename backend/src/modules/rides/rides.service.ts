import { NotificationType, RideStatus, type Prisma } from "@/generated/prisma/client";
import { MemoryCache } from "@/lib/cache/memory-cache";
import { db } from "@/lib/db";
import { env } from "@/lib/env";
import { ForbiddenError, NotFoundError, ConflictError } from "@/lib/http/errors";
import { getSystemConfig } from "@/lib/system-config";
import { paginate } from "@/lib/shared";
import {
  buildSegments,
  scoreRouteMatch,
  walkingMinutes,
  type RouteSegment,
} from "@/modules/matching/matching.service";
import {
  expandSearchBBox,
  searchCacheKey,
  segmentOverlapsBBox,
} from "@/modules/matching/geo";
import type { createRideSchema, rideRequestSchema, searchRidesSchema } from "./rides.schema";
import type { z } from "zod";

type SearchResult = {
  items: ReturnType<typeof scoreAndFilterRides>;
  total: number;
  page: number;
  limit: number;
};

const searchCache = new MemoryCache<SearchResult>(env.SEARCH_CACHE_TTL_SEC * 1000);

async function assertRidePostingAllowed() {
  const config = await getSystemConfig();
  if (config.maintenanceMode) {
    throw new ForbiddenError("Ride posting is disabled during maintenance");
  }
}

export async function createRide(userId: string, input: z.infer<typeof createRideSchema>) {
  await assertRidePostingAllowed();

  const vehicle = await db.vehicle.findFirst({ where: { id: input.vehicleId, userId } });
  if (!vehicle) throw new NotFoundError("Vehicle");

  const segments = buildSegments(input.start, input.end, input.stops);

  const ride = await db.ride.create({
    data: {
      driverId: userId,
      vehicleId: input.vehicleId,
      startAddress: input.start.address,
      startLat: input.start.lat,
      startLng: input.start.lng,
      endAddress: input.end.address,
      endLat: input.end.lat,
      endLng: input.end.lng,
      stops: input.stops,
      segments: segments as unknown as Prisma.InputJsonValue,
      departureAt: input.departureAt,
      repeat: input.repeat,
      availableSeats: input.availableSeats,
      participants: {
        create: { userId, role: "DRIVER", status: "CONFIRMED" },
      },
    },
    include: { vehicle: true, driver: { select: { id: true, fullName: true, photoUrl: true, rating: true } } },
  });

  searchCache.clear();
  return ride;
}

export async function getRideById(rideId: string) {
  const ride = await db.ride.findUnique({
    where: { id: rideId },
    include: {
      vehicle: true,
      driver: { select: { id: true, fullName: true, photoUrl: true, rating: true, rideCount: true } },
      requests: { include: { rider: { select: { id: true, fullName: true, photoUrl: true } } } },
      participants: true,
    },
  });
  if (!ride) throw new NotFoundError("Ride");
  return ride;
}

export async function getMyRidesAsDriver(userId: string) {
  return db.ride.findMany({
    where: { driverId: userId },
    orderBy: { departureAt: "desc" },
    take: 100,
    include: { vehicle: true, requests: true },
  });
}

function buildGeoWhere(
  bbox: ReturnType<typeof expandSearchBBox>,
): Prisma.RideWhereInput {
  return {
    OR: [
      {
        AND: [
          { startLat: { gte: bbox.minLat, lte: bbox.maxLat } },
          { startLng: { gte: bbox.minLng, lte: bbox.maxLng } },
        ],
      },
      {
        AND: [
          { endLat: { gte: bbox.minLat, lte: bbox.maxLat } },
          { endLng: { gte: bbox.minLng, lte: bbox.maxLng } },
        ],
      },
      {
        AND: [
          { startLat: { lte: bbox.maxLat } },
          { endLat: { gte: bbox.minLat } },
          { startLng: { lte: bbox.maxLng } },
          { endLng: { gte: bbox.minLng } },
        ],
      },
    ],
  };
}

function scoreAndFilterRides(
  rides: Awaited<ReturnType<typeof db.ride.findMany>>,
  input: z.infer<typeof searchRidesSchema>,
  riderGender: string | null | undefined,
) {
  const riderFrom = { address: input.fromAddress ?? "", lat: input.fromLat, lng: input.fromLng };
  const riderTo = { address: input.toAddress ?? "", lat: input.toLat, lng: input.toLng };
  const bbox = expandSearchBBox(
    input.fromLat,
    input.fromLng,
    input.toLat,
    input.toLng,
    env.SEARCH_BBOX_BUFFER_KM,
  );

  return rides
    .filter((ride) =>
      segmentOverlapsBBox(ride.startLat, ride.startLng, ride.endLat, ride.endLng, bbox),
    )
    .map((ride) => {
      const driver = (ride as { driver?: { gender?: string | null } }).driver;
      const segments = (ride.segments as unknown as RouteSegment[]) ?? [];
      const matchScore = scoreRouteMatch({ riderFrom, riderTo, driverSegments: segments });
      const walkMin = walkingMinutes(
        Math.hypot(input.fromLat - ride.startLat, input.fromLng - ride.startLng) * 111_000,
      );
      return { ...ride, matchScore, walkMin, driver };
    })
    .filter((r) => {
      if (r.matchScore < input.minMatchScore) return false;
      if (r.walkMin > input.maxWalkingMinutes) return false;
      if (input.genderPreference === "SAME" && riderGender && r.driver?.gender) {
        return r.driver.gender === riderGender;
      }
      return r.matchScore > 0;
    })
    .sort((a, b) => b.matchScore - a.matchScore);
}

export async function searchRides(
  userId: string,
  input: z.infer<typeof searchRidesSchema>,
) {
  const { page, limit, fromLat, fromLng, toLat, toLng, vehicleFilter } = input;

  const cacheKey = `${userId}:${searchCacheKey(input)}`;
  if (env.SEARCH_CACHE_TTL_SEC > 0) {
    const cached = searchCache.get(cacheKey);
    if (cached) return cached;
  }

  const bbox = expandSearchBBox(fromLat, fromLng, toLat, toLng, env.SEARCH_BBOX_BUFFER_KM);

  const rider = await db.user.findUnique({
    where: { id: userId },
    select: { gender: true },
  });

  const where: Prisma.RideWhereInput = {
    status: "OPEN",
    departureAt: { gte: new Date() },
    driverId: { not: userId },
    AND: [buildGeoWhere(bbox)],
    ...(vehicleFilter !== "ANY" ? { vehicle: { type: vehicleFilter } } : {}),
  };

  const rides = await db.ride.findMany({
    where,
    include: {
      vehicle: true,
      driver: {
        select: { id: true, fullName: true, photoUrl: true, rating: true, gender: true },
      },
    },
    orderBy: { departureAt: "asc" },
    take: env.SEARCH_CANDIDATE_CAP,
  });

  const scored = scoreAndFilterRides(rides, input, rider?.gender);

  const { skip, take } = paginate(page, limit);
  const result: SearchResult = {
    items: scored,
    total: scored.length,
    page,
    limit,
  };

  const paged: SearchResult = {
    items: scored.slice(skip, skip + take),
    total: result.total,
    page: result.page,
    limit: result.limit,
  };

  if (env.SEARCH_CACHE_TTL_SEC > 0) {
    searchCache.set(cacheKey, paged);
    searchCache.prune(5_000);
  }

  return paged;
}

export async function requestRide(
  riderId: string,
  rideId: string,
  input: z.infer<typeof rideRequestSchema>,
) {
  const ride = await db.ride.findUnique({ where: { id: rideId } });
  if (!ride || ride.status !== "OPEN") throw new NotFoundError("Ride");
  if (ride.driverId === riderId) throw new ConflictError("Cannot request your own ride");

  const existing = await db.rideRequest.findUnique({
    where: { rideId_riderId: { rideId, riderId } },
  });
  if (existing) throw new ConflictError("Request already exists");

  const request = await db.rideRequest.create({
    data: { rideId, riderId, riderNote: input.riderNote },
  });

  await db.notification.create({
    data: {
      userId: ride.driverId,
      type: NotificationType.RIDE_REQUEST,
      title: "New ride request",
      body: "A rider wants to join your trip",
      payload: { rideId, requestId: request.id },
    },
  });

  return request;
}

export async function respondToRequest(
  driverId: string,
  rideId: string,
  requestId: string,
  accept: boolean,
) {
  const ride = await db.ride.findFirst({ where: { id: rideId, driverId } });
  if (!ride) throw new NotFoundError("Ride");

  const request = await db.rideRequest.findFirst({ where: { id: requestId, rideId } });
  if (!request) throw new NotFoundError("Request");

  const status = accept ? "ACCEPTED" : "DECLINED";

  const updated = await db.$transaction(async (tx) => {
    const req = await tx.rideRequest.update({
      where: { id: requestId },
      data: { status },
    });

    if (accept) {
      await tx.rideParticipant.create({
        data: { rideId, userId: request.riderId, role: "RIDER" },
      });

      const acceptedCount = await tx.rideRequest.count({
        where: { rideId, status: "ACCEPTED" },
      });
      if (acceptedCount >= ride.availableSeats) {
        await tx.ride.update({ where: { id: rideId }, data: { status: "FULL" } });
      }

      const conversation = await tx.conversation.create({
        data: {
          rideId,
          participants: {
            create: [{ userId: driverId }, { userId: request.riderId }],
          },
        },
      });

      await tx.notification.create({
        data: {
          userId: request.riderId,
          type: NotificationType.RIDE_CONFIRMED,
          title: "Ride accepted",
          body: "Your ride request was accepted",
          payload: { rideId, conversationId: conversation.id },
        },
      });
    }

    return req;
  });

  searchCache.clear();
  return updated;
}

export async function updateParticipantStatus(
  rideId: string,
  userId: string,
  status: string,
) {
  return db.rideParticipant.update({
    where: { rideId_userId: { rideId, userId } },
    data: { status: status as "CONFIRMED" },
  });
}

export async function driverHeadingOut(rideId: string, driverId: string) {
  const ride = await db.ride.findFirst({ where: { id: rideId, driverId } });
  if (!ride) throw new NotFoundError("Ride");

  await db.rideParticipant.update({
    where: { rideId_userId: { rideId, userId: driverId } },
    data: { status: "HEADING_OUT" },
  });

  const riders = await db.rideParticipant.findMany({
    where: { rideId, role: "RIDER" },
  });

  await db.notification.createMany({
    data: riders.map((r) => ({
      userId: r.userId,
      type: NotificationType.DRIVER_ETA,
      title: "Driver is heading out",
      body: "Your driver is on the way",
      payload: { rideId },
    })),
  });

  return { notified: riders.length };
}

export async function getLiveRide(rideId: string) {
  return db.ride.findUnique({
    where: { id: rideId },
    include: { participants: { include: { user: { select: { id: true, fullName: true, photoUrl: true } } } } },
  });
}

export async function cancelRide(rideId: string, userId: string) {
  const ride = await db.ride.findFirst({ where: { id: rideId, driverId: userId } });
  if (!ride) throw new NotFoundError("Ride");
  searchCache.clear();
  return db.ride.update({ where: { id: rideId }, data: { status: RideStatus.CANCELLED } });
}

// Regular routes
export async function listRegularRoutes(userId: string) {
  return db.regularRoute.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
}

export async function createRegularRoute(userId: string, input: z.infer<typeof import("./rides.schema").regularRouteSchema>) {
  return db.regularRoute.create({
    data: {
      userId,
      name: input.name,
      startAddress: input.start.address,
      startLat: input.start.lat,
      startLng: input.start.lng,
      endAddress: input.end.address,
      endLat: input.end.lat,
      endLng: input.end.lng,
      stops: input.stops,
      scheduleDays: input.scheduleDays,
      departureTime: input.departureTime,
      defaultSeats: input.defaultSeats,
    },
  });
}

export async function postRideFromRoute(userId: string, routeId: string, departureAt: Date) {
  const route = await db.regularRoute.findFirst({ where: { id: routeId, userId } });
  if (!route) throw new NotFoundError("Regular route");

  const vehicle = await db.vehicle.findFirst({ where: { userId } });
  if (!vehicle) throw new ForbiddenError("Add a vehicle before posting rides");

  return createRide(userId, {
    vehicleId: vehicle.id,
    start: { address: route.startAddress, lat: route.startLat, lng: route.startLng },
    end: { address: route.endAddress, lat: route.endLat, lng: route.endLng },
    stops: (route.stops as { address: string; lat: number; lng: number }[]) ?? [],
    departureAt,
    repeat: "ONCE",
    availableSeats: route.defaultSeats,
  });
}
