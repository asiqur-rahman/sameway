import Redis from "ioredis";
import type { ICacheStore } from "@/domain/ports/cache.port";

/**
 * Shared Redis cache for multi-instance deploys (thousands of concurrent users).
 * Keys are namespaced with `sameway:` to avoid collisions on shared Redis.
 */
export class RedisCacheStore implements ICacheStore {
  private readonly client: Redis;
  private readonly prefix = "sameway:";

  constructor(redisUrl: string) {
    this.client = new Redis(redisUrl, {
      maxRetriesPerRequest: 2,
      enableReadyCheck: true,
      lazyConnect: true,
    });
  }

  private key(key: string) {
    return `${this.prefix}${key}`;
  }

  async get<T>(key: string): Promise<T | undefined> {
    const raw = await this.client.get(this.key(key));
    if (!raw) return undefined;
    try {
      return JSON.parse(raw) as T;
    } catch {
      return undefined;
    }
  }

  async set<T>(key: string, value: T, ttlMs: number): Promise<void> {
    const ttlSec = Math.max(1, Math.ceil(ttlMs / 1000));
    await this.client.set(this.key(key), JSON.stringify(value), "EX", ttlSec);
  }

  async delete(key: string): Promise<void> {
    await this.client.del(this.key(key));
  }

  async deleteByPrefix(prefix: string): Promise<void> {
    const pattern = `${this.prefix}${prefix}*`;
    let cursor = "0";
    do {
      const [next, keys] = await this.client.scan(cursor, "MATCH", pattern, "COUNT", 200);
      cursor = next;
      if (keys.length > 0) {
        await this.client.del(...keys);
      }
    } while (cursor !== "0");
  }

  async clear(): Promise<void> {
    await this.deleteByPrefix("");
  }
}
