import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { searchRidesSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const POST = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const query = parseQuery(request, searchRidesSchema);
  const results = await ridesService.searchRides(session.id, query);
  return ok(results);
});
