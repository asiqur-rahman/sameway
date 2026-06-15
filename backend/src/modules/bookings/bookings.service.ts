import type { Prisma } from "@/generated/prisma/client";
import { db } from "@/lib/db";
import { paginate } from "@/lib/shared";

export async function listNotifications(userId: string, page = 1, limit = 30) {
  const { skip, take } = paginate(page, limit);
  const [items, total] = await Promise.all([
    db.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      skip,
      take,
    }),
    db.notification.count({ where: { userId } }),
  ]);
  return { items, total, page, limit };
}

export async function markRead(notificationId: string, userId: string) {
  return db.notification.updateMany({
    where: { id: notificationId, userId },
    data: { read: true },
  });
}

export async function markAllRead(userId: string) {
  await db.notification.updateMany({ where: { userId, read: false }, data: { read: true } });
  return { ok: true };
}

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

  return { asRider, asDriver };
}