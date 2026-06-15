import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { verificationSchema } from "@/modules/users/users.schema";
import * as usersService from "@/modules/users/users.service";

export const POST = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const body = await parseBody(request, verificationSchema);
  const user = await usersService.submitVerification(session.id, body);
  return ok(user);
});
