import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { reverseGeocodeQuerySchema } from "@/modules/places/places.schema";
import * as placesService from "@/modules/places/places.service";

export const GET = apiRoute(async (request) => {
  await requireAuth(request);
  const { lat, lng } = parseQuery(request, reverseGeocodeQuerySchema);
  const place = await placesService.reverseGeocode(lat, lng);
  return ok(place);
});
