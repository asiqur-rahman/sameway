import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { placeDetailsQuerySchema } from "@/modules/places/places.schema";
import * as placesService from "@/modules/places/places.service";

export const GET = apiRoute(async (request) => {
  await requireAuth(request);
  const { placeId } = parseQuery(request, placeDetailsQuerySchema);
  const place = await placesService.placeDetails(placeId);
  return ok(place);
});
