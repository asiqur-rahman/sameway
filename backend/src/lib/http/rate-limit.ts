import { NextRequest } from "next/server";
import { getRateLimitStore } from "@/infrastructure/rate-limit/create-rate-limit-store";
import { TooManyRequestsError } from "./errors";
import { ipKey, RateLimits, userKey, type RateLimitOptions } from "./rate-limit-presets";

export { ipKey, RateLimits, userKey, type RateLimitOptions };

export async function checkRateLimit(request: NextRequest, options: RateLimitOptions): Promise<void> {
  const id = options.key(request);
  const result = await getRateLimitStore().consume({
    key: id,
    windowSec: options.windowSec,
    max: options.max,
  });

  if (!result.allowed) {
    throw new TooManyRequestsError(result.retryAfterSec ?? options.windowSec);
  }
}
