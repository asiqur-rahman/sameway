import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import * as adminService from "@/modules/admin/admin.service";

export const POST = apiRoute(async (request, { params }) => {
  const admin = await requireAdmin(request);
  const { id } = await params;
  const user = await adminService.rejectVerification(id, admin.id);
  return ok(user);
});
