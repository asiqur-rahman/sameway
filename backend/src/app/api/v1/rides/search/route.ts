import { apiRoute, parseBody, parseQuery } from "@/lib/http/api-route";
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

  let query;
  const contentType = request.headers.get("content-type") ?? "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    const parsed = searchRidesSchema.safeParse(body);
    if (!parsed.success) {
      query = parseQuery(request, searchRidesSchema);
    } else {
      query = parsed.data;
    }
  } else {
    query = parseQuery(request, searchRidesSchema);
  }

  const results = await ridesService.searchRides(session.id, query);
  return ok(results);
});
