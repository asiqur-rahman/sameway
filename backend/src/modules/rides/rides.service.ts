import { NotificationType, RideStatus, type Prisma } from "@/generated/prisma/client";
import { db } from "@/lib/db";
import { ForbiddenError, NotFoundError, ConflictError } from "@/lib/http/errors";
import { paginate } from "@/lib/shared";
import {
  buildSegments,
  scoreRouteMatch,
  walkingMinutes,
  type RouteSegment,
} from "@/modules/matching/matching.service";
import type { createRideSchema, rideRequestSchema, searchRidesSchema } from "./rides.schema";
import type { z } from "zod";

async function assertRidePostingAllowed() {
  const config = await db.systemConfig.findUnique({ where: { id: "default" } });
  if (config?.maintenanceMode) {
    throw new ForbiddenError("Ride posting is disabled during maintenance");
  }
}

export async function createRide(userId: string, input: z.infer<typeof createRideSchema>) {
  await assertRidePostingAllowed();

  const vehicle = await db.vehicle.findFirst({ where: { id: input.vehicleId, userId } });
  if (!vehicle) throw new NotFoundError("Vehicle");

  const segments = buildSegments(input.start, input.end, input.stops);

  return db.ride.create({
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
    include: { vehicle: true, requests: true },
  });
}

export async function searchRides(
  userId: string,
  input: z.infer<typeof searchRidesSchema>,
) {
  const { page, limit, fromLat, fromLng, toLat, toLng, vehicleFilter, maxWalkingMinutes } = input;

  const where: Prisma.RideWhereInput = {
    status: "OPEN",
    departureAt: { gte: new Date() },
    driverId: { not: userId },
    ...(vehicleFilter !== "ANY"
      ? { vehicle: { type: vehicleFilter } }
      : {}),
  };

  const rides = await db.ride.findMany({
    where,
    include: {
      vehicle: true,
      driver: { select: { id: true, fullName: true, photoUrl: true, rating: true, gender: true } },
    },
    orderBy: { departureAt: "asc" },
  });

  const riderFrom = { address: input.fromAddress ?? "", lat: fromLat, lng: fromLng };
  const riderTo = { address: input.toAddress ?? "", lat: toLat, lng: toLng };

  const scored = rides
    .map((ride) => {
      const segments = (ride.segments as unknown as RouteSegment[]) ?? [];
      const matchScore = scoreRouteMatch({ riderFrom, riderTo, driverSegments: segments });
      const walkMin = walkingMinutes(
        Math.hypot(fromLat - ride.startLat, fromLng - ride.startLng) * 111_000,
      );
      return { ...ride, matchScore, walkMin };
    })
    .filter((r) => r.matchScore > 0 && r.walkMin <= maxWalkingMinutes)
    .sort((a, b) => b.matchScore - a.matchScore);

  const { skip, take } = paginate(page, limit);
  return {
    items: scored.slice(skip, skip + take),
    total: scored.length,
    page,
    limit,
  };
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
