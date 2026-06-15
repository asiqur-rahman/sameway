import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as bookingsService from "@/modules/bookings/bookings.service";

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  await bookingsService.markRead(id, session.id);
  return ok({ ok: true });
});
