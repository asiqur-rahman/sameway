import { MemoryCacheStore } from "@/infrastructure/cache/memory-cache.store";
import { RedisCacheStore } from "@/infrastructure/cache/redis-cache.store";
import type { ICacheStore } from "@/domain/ports/cache.port";
import { env } from "@/lib/env";

let cacheStore: ICacheStore | null = null;

/** Singleton cache — Redis when REDIS_URL is set, else bounded in-memory. */
export function getCacheStore(): ICacheStore {
  if (cacheStore) return cacheStore;

  if (env.REDIS_URL) {
    cacheStore = new RedisCacheStore(env.REDIS_URL);
  } else {
    cacheStore = new MemoryCacheStore();
  }

  return cacheStore;
}
