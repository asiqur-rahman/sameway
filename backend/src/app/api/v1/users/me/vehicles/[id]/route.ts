import { apiRoute, parseBody } from "@/lib/http/api-route";
import { noContent, ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { vehicleSchema } from "@/modules/users/users.schema";
import * as usersService from "@/modules/users/users.service";

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const body = await parseBody(request, vehicleSchema.partial());
  const vehicle = await usersService.updateVehicle(session.id, id, body);
  return ok(vehicle);
});

export const DELETE = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  await usersService.deleteVehicle(session.id, id);
  return noContent();
});
