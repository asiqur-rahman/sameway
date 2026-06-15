import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as usersService from "@/modules/users/users.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const status = await usersService.getWorkVerification(session.id);
  return ok(status);
});
