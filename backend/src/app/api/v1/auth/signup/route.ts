import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created } from "@/lib/http/response";
import { signupSchema } from "@/modules/auth/auth.schema";
import * as authService from "@/modules/auth/auth.service";

export const POST = apiRoute(async (request) => {
  const body = await parseBody(request, signupSchema);
  const result = await authService.signup(body);
  return created(result);
});
