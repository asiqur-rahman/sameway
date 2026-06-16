import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { env } from "@/lib/env";
import { autocompleteQuerySchema } from "@/modules/places/places.schema";
import * as placesService from "@/modules/places/places.service";

export const GET = apiRoute(async (request) => {
  await requireAuth(request);
  const { q } = parseQuery(request, autocompleteQuerySchema);

  if (!env.GOOGLE_MAPS_API_KEY) {
    return ok({
      items: [],
      message: "Configure GOOGLE_MAPS_API_KEY for live autocomplete",
      query: q,
    });
  }

  const data = await placesService.autocompletePlaces(q);
  return ok(data);
});
