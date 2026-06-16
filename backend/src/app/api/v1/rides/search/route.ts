import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { env } from "@/lib/env";
import { checkRateLimit, RateLimits } from "@/lib/http/rate-limit";
import { searchRidesSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const POST = apiRoute(async (request) => {
  const session = await requireAuth(request);

  if (env.RATE_LIMIT_ENABLED) {
    checkRateLimit(request, {
      ...RateLimits.searchPerUser(session.id),
      key: () => `user:${session.id}:search`,
    });
  }

  const query = await parseBody(request, searchRidesSchema);
  const results = await ridesService.searchRides(session.id, query);
  return ok(results);
});
