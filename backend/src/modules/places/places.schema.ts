import { z } from "zod";

export const reverseGeocodeQuerySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
});

export const geocodeQuerySchema = z.object({
  q: z.string().min(3).max(300),
});

export const autocompleteQuerySchema = z.object({
  q: z.string().min(1).max(200),
});
