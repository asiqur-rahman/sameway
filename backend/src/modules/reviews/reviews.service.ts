import { db } from "@/lib/db";
import { ConflictError, ForbiddenError } from "@/lib/http/errors";
import type { reviewSchema } from "./reviews.schema";
import type { z } from "zod";

export async function createReview(
  authorId: string,
  rideId: string,
  input: z.infer<typeof reviewSchema>,
) {
  const participant = await db.rideParticipant.findUnique({
    where: { rideId_userId: { rideId, userId: authorId } },
  });
  if (!participant) throw new ForbiddenError("You were not on this ride");

  const existing = await db.review.findUnique({
    where: {
      rideId_authorId_targetUserId: {
        rideId,
        authorId,
        targetUserId: input.targetUserId,
      },
    },
  });
  if (existing) throw new ConflictError("Review already submitted");

  const review = await db.review.create({
    data: { rideId, authorId, ...input },
  });

  const agg = await db.review.aggregate({
    where: { targetUserId: input.targetUserId },
    _avg: { rating: true },
    _count: true,
  });

  await db.user.update({
    where: { id: input.targetUserId },
    data: {
      rating: agg._avg.rating ?? 0,
      rideCount: agg._count,
    },
  });

  return review;
}
