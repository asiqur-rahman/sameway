import { apiRoute } from "@/lib/http/api-route";
import { created } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as ridesService from "@/modules/rides/rides.service";

export const POST = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const departureAt = request.nextUrl.searchParams.get("departureAt");
  if (!departureAt) {
    const { ValidationError } = await import("@/lib/http/errors");
    throw new ValidationError({ formErrors: ["departureAt query param required"], fieldErrors: {} });
  }
  const ride = await ridesService.postRideFromRoute(session.id, id, new Date(departureAt));
  return created(ride);
});
