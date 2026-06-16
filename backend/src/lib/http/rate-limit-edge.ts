import { NextRequest } from "next/server";
import { TooManyRequestsError } from "./errors";
import type { RateLimitOptions } from "./rate-limit-presets";

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

/** In-memory rate limit for the Edge proxy — never imports Redis/ioredis. */
export async function checkEdgeRateLimit(
  request: NextRequest,
  options: RateLimitOptions,
): Promise<void> {
  const id = options.key(request);
  const now = Date.now();
  const windowMs = options.windowSec * 1000;
  let bucket = buckets.get(id);

  if (!bucket || bucket.resetAt <= now) {
    bucket = { count: 0, resetAt: now + windowMs };
    buckets.set(id, bucket);
  }

  bucket.count += 1;
  prune();

  if (bucket.count > options.max) {
    throw new TooManyRequestsError(Math.ceil((bucket.resetAt - now) / 1000));
  }
}
