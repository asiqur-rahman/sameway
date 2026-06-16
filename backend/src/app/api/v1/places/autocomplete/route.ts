import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { autocompleteQuerySchema } from "@/modules/places/places.schema";
import * as placesService from "@/modules/places/places.service";

export const GET = apiRoute(async (request) => {
  await requireAuth(request);
  const { q } = parseQuery(request, autocompleteQuerySchema);
  const data = await placesService.autocompletePlaces(q);
  return ok(data);
});
