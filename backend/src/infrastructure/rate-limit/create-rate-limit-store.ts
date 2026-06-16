import type { IRateLimitStore } from "@/domain/ports/rate-limit.port";
import { MemoryRateLimitStore } from "@/infrastructure/rate-limit/memory-rate-limit.store";
import { RedisRateLimitStore } from "@/infrastructure/rate-limit/redis-rate-limit.store";
import { env } from "@/lib/env";

let store: IRateLimitStore | null = null;

export function getRateLimitStore(): IRateLimitStore {
  if (store) return store;
  store = env.REDIS_URL ? new RedisRateLimitStore(env.REDIS_URL) : new MemoryRateLimitStore();
  return store;
}
