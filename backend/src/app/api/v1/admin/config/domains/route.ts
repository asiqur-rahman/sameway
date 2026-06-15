import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created, ok } from "@/lib/http/response";
import { requireAdmin } from "@/lib/auth/session";
import { allowedDomainSchema } from "@/modules/admin/admin.schema";
import * as adminService from "@/modules/admin/admin.service";

export const GET = apiRoute(async (request) => {
  await requireAdmin(request);
  const domains = await adminService.listDomains();
  return ok(domains);
});

export const POST = apiRoute(async (request) => {
  await requireAdmin(request);
  const body = await parseBody(request, allowedDomainSchema);
  const domain = await adminService.addDomain(body);
  return created(domain);
});
