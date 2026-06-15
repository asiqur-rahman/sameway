import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { paginationSchema } from "@/lib/shared";
import * as notificationsService from "@/modules/notifications/notifications.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const { page, limit } = parseQuery(request, paginationSchema);
  const notifications = await notificationsService.listNotifications(session.id, page, limit);
  return ok(notifications);
});

export const PATCH = apiRoute(async (request) => {
  const session = await requireAuth(request);
  await notificationsService.markAllRead(session.id);
  return ok({ ok: true });
});
