import { db } from "@/lib/db";
import { NotFoundError } from "@/lib/http/errors";
import type {
  deviceTokenSchema,
  placeSchema,
  reminderSettingsSchema,
  updateProfileSchema,
  vehicleSchema,
  verificationSchema,
} from "./users.schema";
import type { z } from "zod";

export async function updateProfile(userId: string, data: z.infer<typeof updateProfileSchema>) {
  return db.user.update({ where: { id: userId }, data });
}

export async function addVehicle(userId: string, data: z.infer<typeof vehicleSchema>) {
  return db.vehicle.create({ data: { ...data, userId } });
}

export async function updateVehicle(
  userId: string,
  vehicleId: string,
  data: Partial<z.infer<typeof vehicleSchema>>,
) {
  const vehicle = await db.vehicle.findFirst({ where: { id: vehicleId, userId } });
  if (!vehicle) throw new NotFoundError("Vehicle");
  return db.vehicle.update({ where: { id: vehicleId }, data });
}

export async function upsertPlace(userId: string, data: z.infer<typeof placeSchema>) {
  return db.place.upsert({
    where: { userId_label: { userId, label: data.label } },
    create: { ...data, userId },
    update: data,
  });
}

export async function submitVerification(userId: string, data: z.infer<typeof verificationSchema>) {
  return db.user.update({
    where: { id: userId },
    data: {
      verificationMethod: data.verificationMethod,
      employeeIdImageUrl: data.employeeIdImageUrl,
      verificationStatus: data.verificationMethod === "SELF_VERIFY" ? "VERIFIED" : "PENDING",
    },
  });
}

export async function updateReminderSettings(
  userId: string,
  data: z.infer<typeof reminderSettingsSchema>,
) {
  return db.reminderSettings.upsert({
    where: { userId },
    create: { userId, ...data },
    update: data,
  });
}

export async function registerDevice(
  userId: string,
  data: z.infer<typeof deviceTokenSchema>,
) {
  return db.deviceToken.upsert({
    where: { token: data.token },
    create: { ...data, userId },
    update: { userId, platform: data.platform },
  });
}

export async function getUserReviews(userId: string) {
  return db.review.findMany({
    where: { targetUserId: userId },
    include: { author: { select: { id: true, fullName: true, photoUrl: true } } },
    orderBy: { createdAt: "desc" },
  });
}
