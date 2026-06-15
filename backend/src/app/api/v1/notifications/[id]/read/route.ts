import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as notificationsService from "@/modules/notifications/notifications.service";

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  await notificationsService.markRead(id, session.id);
  return ok({ ok: true });
});
