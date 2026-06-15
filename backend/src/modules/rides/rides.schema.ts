import { z } from "zod";
import { geoPointSchema, stopSchema } from "@/lib/shared";

export const createRideSchema = z.object({
  vehicleId: z.string().min(1),
  start: geoPointSchema,
  end: geoPointSchema,
  stops: z.array(stopSchema).default([]),
  departureAt: z.coerce.date(),
  repeat: z.enum(["ONCE", "DAILY", "WEEKDAYS"]).default("ONCE"),
  availableSeats: z.number().int().min(1).max(4),
});

export const updateRideSchema = createRideSchema.partial().extend({
  status: z.enum(["OPEN", "FULL", "IN_PROGRESS", "COMPLETED", "CANCELLED"]).optional(),
});

export const searchRidesSchema = z.object({
  fromLat: z.coerce.number(),
  fromLng: z.coerce.number(),
  fromAddress: z.string().optional(),
  toLat: z.coerce.number(),
  toLng: z.coerce.number(),
  toAddress: z.string().optional(),
  vehicleFilter: z.enum(["ANY", "CAR", "BIKE"]).default("ANY"),
  genderPreference: z.enum(["NONE", "SAME"]).default("NONE"),
  minMatchScore: z.coerce.number().min(0).max(100).default(50),
  maxWalkingMinutes: z.coerce.number().int().min(5).max(30).default(15),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const rideRequestSchema = z.object({
  riderNote: z.string().max(500).optional(),
});

export const participantStatusSchema = z.object({
  status: z.enum(["CONFIRMED", "HEADING_OUT", "AT_PICKUP", "ON_WAY", "LATE", "CANCELLED"]),
});

export const regularRouteSchema = z.object({
  name: z.string().max(100).optional(),
  start: geoPointSchema,
  end: geoPointSchema,
  stops: z.array(stopSchema).default([]),
  scheduleDays: z.array(z.number().int().min(0).max(6)).min(1),
  departureTime: z.string().regex(/^\d{2}:\d{2}$/),
  defaultSeats: z.number().int().min(1).max(4).default(1),
});
