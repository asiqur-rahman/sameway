import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { dbHealthCheck, poolStats } from "@/lib/db";
import { purgeExpiredRefreshTokens } from "@/modules/auth/auth.service";

export const GET = apiRoute(async () => {
  const [db, purgedTokens] = await Promise.all([
    dbHealthCheck(),
    purgeExpiredRefreshTokens(),
  ]);

  return ok({
    status: db.ok ? "ok" : "degraded",
    service: "sameway-api",
    version: "1.0.0",
    timestamp: new Date().toISOString(),
    database: db,
    pool: poolStats(),
    maintenance: { purgedRefreshTokens: purgedTokens },
  });
});
