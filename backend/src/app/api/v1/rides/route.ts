import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created, ok } from "@/lib/http/response";
import { requireAuth, requireVerified } from "@/lib/auth/session";
import { createRideSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const POST = apiRoute(async (request) => {
  const session = await requireVerified(request);
  const body = await parseBody(request, createRideSchema);
  const ride = await ridesService.createRide(session.id, body);
  return created(ride);
});

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const rides = await ridesService.getMyRidesAsDriver(session.id);
  return ok(rides);
});
