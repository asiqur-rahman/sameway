import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as ridesService from "@/modules/rides/rides.service";

export const GET = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const ride = await ridesService.getRideById(id);
  if (ride.driverId !== session.id) {
    const { ForbiddenError } = await import("@/lib/http/errors");
    throw new ForbiddenError();
  }
  return ok(ride.requests);
});
