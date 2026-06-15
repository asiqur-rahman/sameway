import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { paginationSchema } from "@/lib/shared";
import { z } from "zod";
import * as bookingsService from "@/modules/bookings/bookings.service";

const querySchema = paginationSchema.extend({
  status: z.enum(["upcoming", "completed"]).optional(),
});

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const { status } = parseQuery(request, querySchema);
  const bookings = await bookingsService.getMyBookings(session.id, status);
  return ok(bookings);
});
