import type { IRateLimitStore, RateLimitCheck } from "@/domain/ports/rate-limit.port";

type Bucket = { count: number; resetAt: number };

const buckets = new Map<string, Bucket>();
const MAX_BUCKETS = 50_000;

function prune() {
  if (buckets.size <= MAX_BUCKETS) return;
  const now = Date.now();
  for (const [key, bucket] of buckets) {
    if (bucket.resetAt <= now) buckets.delete(key);
    if (buckets.size <= MAX_BUCKETS * 0.8) break;
  }
}

export class MemoryRateLimitStore implements IRateLimitStore {
  async consume({ key, windowSec, max }: RateLimitCheck) {
    const now = Date.now();
    const windowMs = windowSec * 1000;
    let bucket = buckets.get(key);

    if (!bucket || bucket.resetAt <= now) {
      bucket = { count: 0, resetAt: now + windowMs };
      buckets.set(key, bucket);
    }

    bucket.count += 1;
    prune();

    if (bucket.count > max) {
      return { allowed: false, retryAfterSec: Math.ceil((bucket.resetAt - now) / 1000) };
    }
    return { allowed: true };
  }
}
