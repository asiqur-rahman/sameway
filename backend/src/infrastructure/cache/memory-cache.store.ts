import { MemoryCache } from "@/lib/cache/memory-cache";
import type { ICacheStore } from "@/domain/ports/cache.port";

export class MemoryCacheStore implements ICacheStore {
  private readonly cache = new MemoryCache<unknown>(60_000);

  async get<T>(key: string): Promise<T | undefined> {
    return this.cache.get(key) as T | undefined;
  }

  async set<T>(key: string, value: T, ttlMs: number): Promise<void> {
    this.cache.set(key, value, ttlMs);
  }

  async delete(key: string): Promise<void> {
    this.cache.delete(key);
  }

  async clear(): Promise<void> {
    this.cache.clear();
  }
}
