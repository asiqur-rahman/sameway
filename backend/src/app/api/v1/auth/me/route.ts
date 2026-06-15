import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as authService from "@/modules/auth/auth.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const user = await authService.getMe(session.id);
  return ok(user);
});
