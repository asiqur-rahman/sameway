import { apiRoute, parseBody } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import { systemConfigSchema } from "@/modules/admin/admin.schema";
import * as adminService from "@/modules/admin/admin.service";

export const GET = apiRoute(async (request) => {
  await requireAdmin(request);
  const config = await adminService.getSystemConfig();
  return ok(config);
});

export const PATCH = apiRoute(async (request) => {
  await requireAdmin(request);
  const body = await parseBody(request, systemConfigSchema);
  const config = await adminService.updateSystemConfig(body);
  return ok(config);
});
