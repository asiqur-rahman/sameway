import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";

export const GET = apiRoute(async () => {
  return ok({
    status: "ok",
    service: "sameway-api",
    version: "1.0.0",
    timestamp: new Date().toISOString(),
  });
});
