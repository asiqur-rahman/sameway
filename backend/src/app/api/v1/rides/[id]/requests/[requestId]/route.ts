import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as ridesService from "@/modules/rides/rides.service";

export const POST = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id, requestId } = await params;
  const result = await ridesService.respondToRequest(session.id, id, requestId, true);
  return ok(result);
});

export const DELETE = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id, requestId } = await params;
  const result = await ridesService.respondToRequest(session.id, id, requestId, false);
  return ok(result);
});
