import { z } from "zod";
import { isValidCoordinate } from "@/modules/places/places.service";

export const updateProfileSchema = z.object({
  fullName: z.string().min(2).max(100).optional(),
  photoUrl: z.string().url().optional(),
  commuteType: z.enum(["DRIVE", "RIDE", "WALK", "BOTH"]).optional(),
  companyName: z.string().max(120).optional(),
  designation: z.string().max(120).optional(),
  idVisibility: z.enum(["ADMIN_ONLY", "PUBLIC_TO_RIDERS"]).optional(),
  gender: z.enum(["MALE", "FEMALE", "OTHER", "PREFER_NOT_TO_SAY"]).optional(),
});

export const vehicleSchema = z.object({
  type: z.enum(["CAR", "BIKE"]),
  makeModel: z.string().min(1).max(100),
  licensePlate: z.string().min(1).max(20),
  availableSeats: z.number().int().min(1).max(4).default(1),
  year: z.number().int().min(1990).max(2030).optional(),
  color: z.string().max(50).optional(),
  usuallyLeave: z.string().max(20).optional(),
  latestDepart: z.string().max(20).optional(),
  riderPreference: z.string().max(50).optional(),
});

export const commutePreferencesSchema = z.object({
  preferredVehicle: z.enum(["Any", "Car only", "Bike ok"]).optional(),
  genderPreference: z.enum(["No preference", "Same gender"]).optional(),
  maxWalkMinutes: z.number().int().min(5).max(30).optional(),
  leaveBy: z.string().max(20).optional(),
  arriveBy: z.string().max(20).optional(),
  walkWithOthers: z.boolean().optional(),
  walkingPace: z.enum(["Leisurely", "Normal", "Brisk"]).optional(),
});

export const placeSchema = z.object({
  label: z.enum(["HOME", "OFFICE", "CUSTOM"]),
  address: z.string().min(1),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
}).superRefine((data, ctx) => {
  if ((data.label === "OFFICE" || data.label === "HOME") && !isValidCoordinate(data.lat, data.lng)) {
    ctx.addIssue({
      code: "custom",
      message:
        data.label === "OFFICE"
          ? "Office address must be selected on the map"
          : "Home address must include map coordinates — pin on map or geocode",
      path: ["lat"],
    });
  }
});

export const verificationSchema = z.object({
  verificationMethod: z.enum(["ADMIN_ONLY", "SELF_VERIFY"]),
  employeeIdImageUrl: z.string().url(),
});

export const reminderSettingsSchema = z.object({
  driverDeparture: z.boolean().optional(),
  driverNotifyRiders: z.boolean().optional(),
  riderPickup: z.boolean().optional(),
  riderLetDriverKnow: z.boolean().optional(),
  dailySummary: z.boolean().optional(),
});

export const deviceTokenSchema = z.object({
  token: z.string().min(1),
  platform: z.enum(["ios", "android", "web"]),
});
