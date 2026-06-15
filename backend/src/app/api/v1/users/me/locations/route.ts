import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { placeSchema } from "@/modules/users/users.schema";
import * as usersService from "@/modules/users/users.service";

export const POST = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const body = await parseBody(request, placeSchema);
  const place = await usersService.upsertPlace(session.id, body);
  return ok(place);
});
