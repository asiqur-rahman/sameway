import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import * as adminService from "@/modules/admin/admin.service";

export const DELETE = apiRoute(async (request, { params }) => {
  await requireAdmin(request);
  const { domain } = await params;
  const result = await adminService.removeDomain(decodeURIComponent(domain));
  return ok(result);
});
