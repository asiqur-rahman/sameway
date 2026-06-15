import { db } from "@/lib/db";
import { NotFoundError, ValidationError } from "@/lib/http/errors";
import type {
  commutePreferencesSchema,
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

export async function upsertCommutePreferences(
  userId: string,
  data: z.infer<typeof commutePreferencesSchema>,
) {
  return db.commutePreferences.upsert({
    where: { userId },
    create: { userId, ...data },
    update: data,
  });
}

export async function getCommutePreferences(userId: string) {
  return db.commutePreferences.findUnique({ where: { userId } });
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

export async function deleteVehicle(userId: string, vehicleId: string) {
  const vehicle = await db.vehicle.findFirst({ where: { id: vehicleId, userId } });
  if (!vehicle) throw new NotFoundError("Vehicle");
  await db.vehicle.delete({ where: { id: vehicleId } });
}

export async function getReminderSettings(userId: string) {
  return db.reminderSettings.findUnique({ where: { userId } });
}

export async function upsertPlace(userId: string, data: z.infer<typeof placeSchema>) {
  if (data.label === "OFFICE" && data.lat === 0 && data.lng === 0) {
    throw new ValidationError({
      formErrors: ["Office address must be selected on the map"],
      fieldErrors: {},
    });
  }

  const place = await db.place.upsert({
    where: { userId_label: { userId, label: data.label } },
    create: { ...data, userId },
    update: data,
  });

  if (data.label === "OFFICE") {
    await db.user.update({
      where: { id: userId },
      data: { officeLocationVerified: true },
    });
  }

  return place;
}

export async function submitVerification(userId: string, data: z.infer<typeof verificationSchema>) {
  return db.user.update({
    where: { id: userId },
    data: {
      verificationMethod: data.verificationMethod,
      employeeIdImageUrl: data.employeeIdImageUrl,
      employeeIdVerified: true,
      verificationStatus: data.verificationMethod === "SELF_VERIFY" ? "VERIFIED" : "PENDING",
    },
  });
}

export function getWorkVerificationStatus(user: {
  workEmailVerified: boolean;
  officeLocationVerified: boolean;
  employeeIdVerified: boolean;
}) {
  const steps = [
    { key: "email", title: "Work email", completed: user.workEmailVerified },
    { key: "office", title: "Office on map", completed: user.officeLocationVerified },
    { key: "employeeId", title: "Employee ID", completed: user.employeeIdVerified },
  ] as const;

  return {
    steps,
    completedCount: steps.filter((s) => s.completed).length,
    totalSteps: steps.length,
    isComplete: steps.every((s) => s.completed),
  };
}

export async function getWorkVerification(userId: string) {
  const user = await db.user.findUnique({
    where: { id: userId },
    select: {
      workEmailVerified: true,
      officeLocationVerified: true,
      employeeIdVerified: true,
      places: { where: { label: "OFFICE" } },
    },
  });
  if (!user) throw new NotFoundError("User");
  return {
    ...getWorkVerificationStatus(user),
    office: user.places[0] ?? null,
  };
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
