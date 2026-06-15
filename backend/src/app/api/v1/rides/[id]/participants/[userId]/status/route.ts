import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { participantStatusSchema } from "@/modules/rides/rides.schema";
import * as ridesService from "@/modules/rides/rides.service";

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id, userId } = await params;
  if (session.id !== userId) {
    const { ForbiddenError } = await import("@/lib/http/errors");
    throw new ForbiddenError();
  }
  const body = await parseBody(request, participantStatusSchema);
  const result = await ridesService.updateParticipantStatus(id, userId, body.status);
  return ok(result);
});
