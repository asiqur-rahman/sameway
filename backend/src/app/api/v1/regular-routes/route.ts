import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created, ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { regularRouteSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const routes = await ridesService.listRegularRoutes(session.id);
  return ok(routes);
});

export const POST = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const body = await parseBody(request, regularRouteSchema);
  const route = await ridesService.createRegularRoute(session.id, body);
  return created(route);
});
