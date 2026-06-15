import { apiRoute, parseBody } from "@/lib/http/api-route";
import { noContent, ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { regularRouteSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const body = await parseBody(request, regularRouteSchema.partial());
  const route = await ridesService.updateRegularRoute(session.id, id, body);
  return ok(route);
});

export const DELETE = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  await ridesService.deleteRegularRoute(session.id, id);
  return noContent();
});
