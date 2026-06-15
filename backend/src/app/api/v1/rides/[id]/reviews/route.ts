import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { reviewSchema } from "@/modules/reviews/reviews.schema";
import * as reviewsService from "@/modules/reviews/reviews.service";

export const POST = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const body = await parseBody(request, reviewSchema);
  const review = await reviewsService.createReview(session.id, id, body);
  return created(review);
});
