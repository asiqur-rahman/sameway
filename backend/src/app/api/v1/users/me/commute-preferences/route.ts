import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { commutePreferencesSchema } from "@/modules/users/users.schema";
import * as usersService from "@/modules/users/users.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const prefs = await usersService.getCommutePreferences(session.id);
  return ok(prefs);
});

export const PATCH = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const body = await parseBody(request, commutePreferencesSchema);
  const prefs = await usersService.upsertCommutePreferences(session.id, body);
  return ok(prefs);
});
