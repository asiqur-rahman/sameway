import { apiRoute, parseBody } from "@/lib/http/api-route";
import { noContent, ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { z } from "zod";
import * as ridesService from "@/modules/rides/rides.service";

const statusSchema = z.object({
  status: z.enum(["OPEN", "FULL", "IN_PROGRESS", "COMPLETED", "CANCELLED"]),
});

export const GET = apiRoute(async (_request, { params }) => {
  const { id } = await params;
  const ride = await ridesService.getRideById(id);
  return ok(ride);
});

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const body = await parseBody(request, statusSchema);
  const ride = await ridesService.updateRideStatus(id, session.id, body.status);
  return ok(ride);
});

export const DELETE = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  await ridesService.cancelRide(id, session.id);
  return noContent();
});
