import type { Prisma } from "@/generated/prisma/client";
import { db } from "@/lib/db";
import { toDriverBookingDto } from "@/application/mappers/ride.mapper";
import * as notificationsService from "@/modules/notifications/notifications.service";

export { listNotifications, markRead, markAllRead } from "@/modules/notifications/notifications.service";

function buildRideFilter(status?: "upcoming" | "completed"): Prisma.RideWhereInput {
  const now = new Date();
  if (status === "upcoming") {
    return {
      departureAt: { gte: now },
      status: { notIn: ["CANCELLED", "COMPLETED"] },
    };
  }
  if (status === "completed") {
    return {
      OR: [{ status: "COMPLETED" }, { departureAt: { lt: now } }],
    };
  }
  return {};
}

export async function getMyBookings(userId: string, status?: "upcoming" | "completed") {
  const rideFilter = buildRideFilter(status);

  const asRider = await db.rideRequest.findMany({
    where: { riderId: userId, status: "ACCEPTED", ride: rideFilter },
    include: {
      ride: {
        include: {
          driver: { select: { id: true, fullName: true, photoUrl: true } },
          vehicle: true,
          conversations: { select: { id: true }, take: 1 },
        },
      },
    },
    orderBy: { ride: { departureAt: "desc" } },
  });

  const asDriver = await db.ride.findMany({
    where: { driverId: userId, ...rideFilter },
    include: { vehicle: true, requests: { where: { status: "ACCEPTED" } } },
    orderBy: { departureAt: "desc" },
  });

  return {
    asRider: asRider.map((r) => ({
      id: r.ride.id,
      route: `${r.ride.startAddress} → ${r.ride.endAddress}`,
      from: r.ride.startAddress,
      to: r.ride.endAddress,
      timeLabel: r.ride.departureAt.toISOString(),
      detail: `Driver: ${r.ride.driver.fullName} · ${r.ride.availableSeats} seats`,
      status: r.status.toLowerCase(),
      driverName: r.ride.driver.fullName,
      isDriver: false,
      chatThreadId: r.ride.conversations[0]?.id ?? null,
    })),
    asDriver: asDriver.map(toDriverBookingDto),
    unreadNotifications: (await notificationsService.listNotifications(userId, 1, 1)).unreadCount,
  };
}
