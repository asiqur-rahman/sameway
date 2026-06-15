import { NextRequest } from "next/server";
import { TooManyRequestsError } from "./errors";

type Bucket = { count: number; resetAt: number };

const buckets = new Map<string, Bucket>();

/** Max tracked keys — evict oldest when exceeded (DoS guard). */
const MAX_BUCKETS = 50_000;

export type RateLimitOptions = {
  /** Window length in seconds. */
  windowSec: number;
  /** Max requests per window. */
  max: number;
  /** Build a key from the request (IP, user id, etc.). */
  key: (request: NextRequest) => string;
};

function clientIp(request: NextRequest): string {
  const forwarded = request.headers.get("x-forwarded-for");
  if (forwarded) return forwarded.split(",")[0]?.trim() ?? "unknown";
  return request.headers.get("x-real-ip") ?? "unknown";
}

export function ipKey(request: NextRequest, suffix = ""): string {
  return `ip:${clientIp(request)}${suffix ? `:${suffix}` : ""}`;
}

export function userKey(userId: string, suffix: string): string {
  return `user:${userId}:${suffix}`;
}

function pruneBuckets() {
  if (buckets.size <= MAX_BUCKETS) return;
  const now = Date.now();
  for (const [key, bucket] of buckets) {
    if (bucket.resetAt <= now) buckets.delete(key);
    if (buckets.size <= MAX_BUCKETS * 0.8) break;
  }
  if (buckets.size > MAX_BUCKETS) {
    const toDrop = buckets.size - MAX_BUCKETS;
    const keys = buckets.keys();
    for (let i = 0; i < toDrop; i++) {
      const next = keys.next();
      if (next.done) break;
      buckets.delete(next.value);
    }
  }
}

export function checkRateLimit(request: NextRequest, options: RateLimitOptions): void {
  const now = Date.now();
  const windowMs = options.windowSec * 1000;
  const id = options.key(request);
  let bucket = buckets.get(id);

  if (!bucket || bucket.resetAt <= now) {
    bucket = { count: 0, resetAt: now + windowMs };
    buckets.set(id, bucket);
  }

  bucket.count += 1;
  pruneBuckets();

  if (bucket.count > options.max) {
    const retryAfterSec = Math.ceil((bucket.resetAt - now) / 1000);
    throw new TooManyRequestsError(retryAfterSec);
  }
}

/** Presets tuned for commute-app peak hours (morning/evening rush). */
export const RateLimits = {
  auth: { windowSec: 60, max: 15, key: (r: NextRequest) => ipKey(r, "auth") },
  signup: { windowSec: 60, max: 8, key: (r: NextRequest) => ipKey(r, "signup") },
  search: { windowSec: 60, max: 45, key: (r: NextRequest) => ipKey(r, "search") },
  searchPerUser: (userId: string) => ({
    windowSec: 60,
    max: 30,
    key: () => userKey(userId, "search"),
  }),
  chatSend: (userId: string) => ({
    windowSec: 60,
    max: 60,
    key: () => userKey(userId, "chat"),
  }),
  general: { windowSec: 60, max: 120, key: (r: NextRequest) => ipKey(r, "api") },
} as const;
