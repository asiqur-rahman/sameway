import type { Prisma } from "@/generated/prisma/client";
import { NotificationType, ParticipantStatus, RideStatus } from "@/generated/prisma/client";
import { container } from "@/application/container";
import { toLiveRideDto, toRideDetailDto, toTodayRideSummary } from "@/application/mappers/ride.mapper";
import { db } from "@/lib/db";
import { ForbiddenError, NotFoundError, ConflictError } from "@/lib/http/errors";
import { getSystemConfig } from "@/lib/system-config";
import { notifyUser } from "@/infrastructure/outbox/notification-outbox";
import {
  buildSegments,
  scoreRouteMatch,
} from "@/modules/matching/matching.service";
import type { RouteSegment } from "@/modules/matching/matching.service";
import { fetchRoadSegments } from "@/lib/routing/osrm.client";
import type { GeoPoint } from "@/lib/shared";
import type { createRideSchema, rideRequestSchema, searchRidesSchema } from "./rides.schema";
import type { z } from "zod";

async function assertRidePostingAllowed() {
  const config = await getSystemConfig();
  if (config.maintenanceMode) {
    throw new ForbiddenError("Ride posting is disabled during maintenance");
  }
}

async function invalidateSearchCache() {
  await container.searchRides.invalidateCache();
}

export async function createRide(userId: string, input: z.infer<typeof createRideSchema>) {
  await assertRidePostingAllowed();

  const vehicle = await db.vehicle.findFirst({ where: { id: input.vehicleId, userId } });
  if (!vehicle) throw new NotFoundError("Vehicle");

  // Fetch road-snapped polyline from OSRM; fall back to straight-line segments
  // if OSRM is not configured or temporarily unavailable.
  const waypoints = [input.start, ...input.stops, input.end];
  const roadSegments = await fetchRoadSegments(waypoints);
  const segments = roadSegments.length >= 1
    ? roadSegments
    : buildSegments(input.start, input.end, input.stops);

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

  await invalidateSearchCache();
  return ride;
}

export async function getIncomingRequests(driverId: string, rideId: string) {
  const ride = await db.ride.findFirst({ where: { id: rideId, driverId } });
  if (!ride) throw new NotFoundError("Ride");
  return db.rideRequest.findMany({
    where: { rideId, status: "PENDING" },
    include: { rider: { select: { id: true, fullName: true, photoUrl: true, rating: true } } },
    orderBy: { createdAt: "desc" },
  });
}

export async function getRideById(rideId: string) {
  const ride = await container.rideRepository.findById(rideId);
  if (!ride) throw new NotFoundError("Ride");
  return toRideDetailDto(ride);
}

export async function getMyRidesAsDriver(userId: string) {
  return container.rideRepository.listByDriver(userId);
}

export async function searchRides(userId: string, input: z.infer<typeof searchRidesSchema>) {
  return container.searchRides.execute(userId, input);
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

  const riderPlaces = await db.place.findMany({
    where: { userId: riderId, label: { in: ["HOME", "OFFICE"] } },
  });
  const home = riderPlaces.find((p) => p.label === "HOME");
  const office = riderPlaces.find((p) => p.label === "OFFICE");

  let matchScore: number | undefined;
  let pickupSegment: Prisma.InputJsonValue | undefined;

  if (home && office) {
    const stops = (ride.stops as GeoPoint[] | null) ?? [];
    const segments =
      (ride.segments as unknown as RouteSegment[]) ??
      buildSegments(
        { address: ride.startAddress, lat: ride.startLat, lng: ride.startLng },
        { address: ride.endAddress, lat: ride.endLat, lng: ride.endLng },
        stops,
      );
    matchScore = scoreRouteMatch({
      riderFrom: { address: home.address, lat: home.lat, lng: home.lng },
      riderTo: { address: office.address, lat: office.lat, lng: office.lng },
      driverSegments: segments,
    });
    pickupSegment = (segments[0] ?? null) as Prisma.InputJsonValue;
  }

  const request = await db.rideRequest.create({
    data: {
      rideId,
      riderId,
      riderNote: input.riderNote,
      matchScore,
      pickupSegment,
    },
  });

  await notifyUser({
    userId: ride.driverId,
    type: NotificationType.RIDE_REQUEST,
    title: "New ride request",
    body: "A rider wants to join your trip",
    payload: { rideId, requestId: request.id },
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
      await tx.notificationOutbox.create({
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

  await invalidateSearchCache();
  return updated;
}

export async function cancelRide(rideId: string, driverId: string) {
  const ride = await container.cancelRide.execute(rideId, driverId);
  await invalidateSearchCache();
  return ride;
}

export async function updateRideStatus(
  rideId: string,
  driverId: string,
  status: RideStatus,
) {
  const ride = await container.updateRideStatus.execute(rideId, driverId, status);
  await invalidateSearchCache();
  return ride;
}

export async function updateParticipantStatus(
  rideId: string,
  userId: string,
  status: string,
) {
  const participant = await db.rideParticipant.findUnique({
    where: { rideId_userId: { rideId, userId } },
  });
  if (!participant) throw new NotFoundError("Participant");

  return db.rideParticipant.update({
    where: { rideId_userId: { rideId, userId } },
    data: { status: status as ParticipantStatus },
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

  const { notifyMany } = await import("@/infrastructure/outbox/notification-outbox");
  await notifyMany(
    riders.map((r) => ({
      userId: r.userId,
      type: NotificationType.DRIVER_ETA,
      title: "Driver is heading out",
      body: "Your driver is on the way",
      payload: { rideId },
    })),
  );

  return { notified: riders.length };
}

export async function getLiveRide(rideId: string, viewerUserId: string) {
  const ride = await db.ride.findUnique({
    where: { id: rideId },
    include: {
      vehicle: true,
      driver: { select: { id: true, fullName: true, photoUrl: true, rating: true, rideCount: true, verificationStatus: true, gender: true, companyDomain: true } },
      participants: {
        include: { user: { select: { id: true, fullName: true, photoUrl: true } } },
      },
    },
  });
  if (!ride) throw new NotFoundError("Ride");

  const isParticipant = ride.participants.some((p) => p.userId === viewerUserId);
  if (!isParticipant && ride.driverId !== viewerUserId) {
    throw new ForbiddenError("Not a participant on this ride");
  }

  return toLiveRideDto(ride as Parameters<typeof toLiveRideDto>[0], viewerUserId);
}

export async function getTodayRide(userId: string) {
  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);
  const endOfDay = new Date(startOfDay);
  endOfDay.setDate(endOfDay.getDate() + 1);

  const ride = await db.ride.findFirst({
    where: {
      status: { in: ["OPEN", "FULL", "IN_PROGRESS"] },
      departureAt: { gte: startOfDay, lt: endOfDay },
      OR: [
        { driverId: userId },
        { participants: { some: { userId, role: "RIDER" } } },
      ],
    },
    include: {
      vehicle: true,
      driver: { select: { id: true, fullName: true, photoUrl: true, rating: true, rideCount: true, verificationStatus: true, gender: true, companyDomain: true } },
      participants: {
        include: { user: { select: { id: true, fullName: true, photoUrl: true } } },
      },
    },
    orderBy: { departureAt: "asc" },
  });

  if (!ride) return null;
  return toTodayRideSummary(ride as Parameters<typeof toTodayRideSummary>[0], userId);
}

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

export async function updateRegularRoute(
  userId: string,
  routeId: string,
  data: Partial<z.infer<typeof import("./rides.schema").regularRouteSchema>>,
) {
  const route = await db.regularRoute.findFirst({ where: { id: routeId, userId } });
  if (!route) throw new NotFoundError("Regular route");
  return db.regularRoute.update({
    where: { id: routeId },
    data: {
      name: data.name,
      scheduleDays: data.scheduleDays,
      departureTime: data.departureTime,
      defaultSeats: data.defaultSeats,
      ...(data.start
        ? {
            startAddress: data.start.address,
            startLat: data.start.lat,
            startLng: data.start.lng,
          }
        : {}),
      ...(data.end
        ? {
            endAddress: data.end.address,
            endLat: data.end.lat,
            endLng: data.end.lng,
          }
        : {}),
      ...(data.stops ? { stops: data.stops } : {}),
    },
  });
}

export async function deleteRegularRoute(userId: string, routeId: string) {
  const route = await db.regularRoute.findFirst({ where: { id: routeId, userId } });
  if (!route) throw new NotFoundError("Regular route");
  await db.regularRoute.delete({ where: { id: routeId } });
  return { ok: true };
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
