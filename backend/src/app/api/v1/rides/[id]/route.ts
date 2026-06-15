import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import * as ridesService from "@/modules/rides/rides.service";

export const GET = apiRoute(async (_request, { params }) => {
  const { id } = await params;
  const ride = await ridesService.getRideById(id);
  return ok(ride);
});
