import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { rideRequestSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const POST = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const body = await parseBody(request, rideRequestSchema);
  const result = await ridesService.requestRide(session.id, id, body);
  return created(result);
});
