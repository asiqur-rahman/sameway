import { z } from "zod";
import { isValidCoordinate } from "@/modules/places/places.service";

export const geoPointSchema = z
  .object({
    address: z.string().min(1),
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
  })
  .superRefine((data, ctx) => {
    if (!isValidCoordinate(data.lat, data.lng)) {
      ctx.addIssue({
        code: "custom",
        message: "Valid map coordinates are required",
        path: ["lat"],
      });
    }
  });

export const stopSchema = geoPointSchema.extend({
  order: z.number().int().min(0).optional(),
});

export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type GeoPoint = z.infer<typeof geoPointSchema>;
export type Stop = z.infer<typeof stopSchema>;

export function omitPassword<T extends { passwordHash?: string }>(user: T) {
  const { passwordHash: _, ...safe } = user;
  return safe;
}

export function paginate(page: number, limit: number) {
  return { skip: (page - 1) * limit, take: limit };
}
