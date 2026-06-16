import Redis from "ioredis";
import type { IRateLimitStore, RateLimitCheck } from "@/domain/ports/rate-limit.port";

/** Fixed-window rate limiting shared across API instances. */
export class RedisRateLimitStore implements IRateLimitStore {
  private readonly client: Redis;
  private readonly prefix = "sameway:rl:";

  constructor(redisUrl: string) {
    this.client = new Redis(redisUrl, {
      maxRetriesPerRequest: 2,
      enableReadyCheck: true,
      lazyConnect: true,
    });
  }

  async consume({ key, windowSec, max }: RateLimitCheck) {
    const redisKey = `${this.prefix}${key}`;
    const windowMs = windowSec * 1000;
    const count = await this.client.incr(redisKey);
    if (count === 1) {
      await this.client.pexpire(redisKey, windowMs);
    }
    if (count > max) {
      const ttlMs = await this.client.pttl(redisKey);
      return {
        allowed: false,
        retryAfterSec: Math.max(1, Math.ceil((ttlMs > 0 ? ttlMs : windowMs) / 1000)),
      };
    }
    return { allowed: true };
  }
}
