import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import { paginationSchema } from "@/lib/shared";
import * as adminService from "@/modules/admin/admin.service";

export const GET = apiRoute(async (request) => {
  await requireAdmin(request);
  const { page, limit } = parseQuery(request, paginationSchema);
  const users = await adminService.listUsers(page, limit);
  return ok(users);
});
