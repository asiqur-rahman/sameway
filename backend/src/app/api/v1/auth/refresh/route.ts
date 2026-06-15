import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok, noContent } from "@/lib/http/response";
import { refreshSchema } from "@/modules/auth/auth.schema";
import * as authService from "@/modules/auth/auth.service";

export const POST = apiRoute(async (request) => {
  const body = await parseBody(request, refreshSchema);
  const result = await authService.refresh(body.refreshToken);
  return ok(result);
});

export const DELETE = apiRoute(async (request) => {
  const body = await parseBody(request, refreshSchema);
  await authService.logout(body.refreshToken);
  return noContent();
});
