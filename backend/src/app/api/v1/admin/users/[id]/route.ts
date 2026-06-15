import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import { userStatusSchema } from "@/modules/admin/admin.schema";
import * as adminService from "@/modules/admin/admin.service";

export const PATCH = apiRoute(async (request, { params }) => {
  await requireAdmin(request);
  const { id } = await params;
  const body = await parseBody(request, userStatusSchema);
  const user = await adminService.updateUser(id, body);
  return ok(user);
});
