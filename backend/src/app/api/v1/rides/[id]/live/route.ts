import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as ridesService from "@/modules/rides/rides.service";

export const GET = apiRoute(async (request, { params }) => {
  await requireAuth(request);
  const { id } = await params;
  const live = await ridesService.getLiveRide(id);
  return ok(live);
});
