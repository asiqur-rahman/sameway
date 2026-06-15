import { db } from "@/lib/db";
import { MemoryCache } from "@/lib/cache/memory-cache";

type SystemConfigSnapshot = {
  maintenanceMode: boolean;
  autoVerifyKnownDomains: boolean;
};

const cache = new MemoryCache<SystemConfigSnapshot>(30_000);

export async function getSystemConfig(): Promise<SystemConfigSnapshot> {
  const cached = cache.get("default");
  if (cached) return cached;

  const config = await db.systemConfig.findUnique({ where: { id: "default" } });
  const snapshot: SystemConfigSnapshot = {
    maintenanceMode: config?.maintenanceMode ?? false,
    autoVerifyKnownDomains: config?.autoVerifyKnownDomains ?? true,
  };
  cache.set("default", snapshot);
  return snapshot;
}

export function invalidateSystemConfigCache() {
  cache.delete("default");
}
