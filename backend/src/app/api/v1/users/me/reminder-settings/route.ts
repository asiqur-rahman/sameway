import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { reminderSettingsSchema } from "@/modules/users/users.schema";
import * as usersService from "@/modules/users/users.service";

export const PATCH = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const body = await parseBody(request, reminderSettingsSchema);
  const settings = await usersService.updateReminderSettings(session.id, body);
  return ok(settings);
});
