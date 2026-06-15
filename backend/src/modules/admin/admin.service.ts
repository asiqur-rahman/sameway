import { db } from "@/lib/db";
import { NotFoundError } from "@/lib/http/errors";
import { invalidateSystemConfigCache } from "@/lib/system-config";
import type { z } from "zod";
import type { allowedDomainSchema, systemConfigSchema, userStatusSchema } from "./admin.schema";

export async function getDashboardStats() {
  const [users, pendingVerifications, activeRides, completedRides] = await Promise.all([
    db.user.count(),
    db.user.count({ where: { verificationStatus: "PENDING" } }),
    db.ride.count({ where: { status: { in: ["OPEN", "FULL", "IN_PROGRESS"] } } }),
    db.ride.count({ where: { status: "COMPLETED" } }),
  ]);
  return { users, pendingVerifications, activeRides, completedRides };
}

export async function getActivityLog(limit = 50) {
  return db.adminActivityLog.findMany({ orderBy: { createdAt: "desc" }, take: limit });
}

export async function listUsers(page = 1, limit = 20) {
  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    db.user.findMany({
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        fullName: true,
        workEmail: true,
        phone: true,
        verificationStatus: true,
        role: true,
        rating: true,
        createdAt: true,
      },
    }),
    db.user.count(),
  ]);
  return { items, total, page, limit };
}

export async function updateUser(userId: string, data: z.infer<typeof userStatusSchema>) {
  const user = await db.user.findUnique({ where: { id: userId } });
  if (!user) throw new NotFoundError("User");
  return db.user.update({ where: { id: userId }, data });
}

export async function listPendingVerifications() {
  return db.user.findMany({
    where: { verificationStatus: "PENDING", employeeIdImageUrl: { not: null } },
    select: {
      id: true,
      fullName: true,
      workEmail: true,
      employeeIdImageUrl: true,
      verificationMethod: true,
      createdAt: true,
    },
  });
}

export async function approveVerification(userId: string, adminId: string) {
  const user = await db.user.update({
    where: { id: userId },
    data: { verificationStatus: "VERIFIED" },
  });
  await logActivity("verification.approved", adminId, { userId });
  return user;
}

export async function rejectVerification(userId: string, adminId: string) {
  const user = await db.user.update({
    where: { id: userId },
    data: { verificationStatus: "REJECTED" },
  });
  await logActivity("verification.rejected", adminId, { userId });
  return user;
}

export async function listDomains() {
  return db.allowedDomain.findMany({ orderBy: { domain: "asc" } });
}

export async function addDomain(data: z.infer<typeof allowedDomainSchema>) {
  const domain = await db.allowedDomain.create({ data });
  return domain;
}

export async function removeDomain(domain: string) {
  await db.allowedDomain.delete({ where: { domain } });
  return { ok: true };
}

export async function getSystemConfig() {
  return db.systemConfig.upsert({
    where: { id: "default" },
    create: {},
    update: {},
  });
}

export async function updateSystemConfig(data: z.infer<typeof systemConfigSchema>) {
  const updated = await db.systemConfig.upsert({
    where: { id: "default" },
    create: data,
    update: data,
  });
  invalidateSystemConfigCache();
  return updated;
}

async function logActivity(event: string, userId: string | null, details?: unknown) {
  await db.adminActivityLog.create({
    data: { event, userId, details: details as object },
  });
}
