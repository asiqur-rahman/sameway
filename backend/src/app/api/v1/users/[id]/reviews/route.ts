import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import * as usersService from "@/modules/users/users.service";

export const GET = apiRoute(async (_request, { params }) => {
  const { id } = await params;
  const reviews = await usersService.getUserReviews(id);
  return ok(reviews);
});
