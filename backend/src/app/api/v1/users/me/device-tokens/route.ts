import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { deviceTokenSchema } from "@/modules/users/users.schema";
import * as usersService from "@/modules/users/users.service";

export const POST = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const body = await parseBody(request, deviceTokenSchema);
  const token = await usersService.registerDevice(session.id, body);
  return created(token);
});
