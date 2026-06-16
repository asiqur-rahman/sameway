import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as ridesService from "@/modules/rides/rides.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const today = await ridesService.getTodayRide(session.id);
  return ok({ ride: today });
});
