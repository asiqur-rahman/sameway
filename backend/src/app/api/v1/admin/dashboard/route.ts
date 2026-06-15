import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import * as adminService from "@/modules/admin/admin.service";

export const GET = apiRoute(async (request) => {
  await requireAdmin(request);
  const stats = await adminService.getDashboardStats();
  return ok(stats);
});
