import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { signinSchema } from "@/modules/auth/auth.schema";
import * as authService from "@/modules/auth/auth.service";

export const POST = apiRoute(async (request) => {
  const body = await parseBody(request, signinSchema);
  const result = await authService.signin(body);
  return ok(result);
});
