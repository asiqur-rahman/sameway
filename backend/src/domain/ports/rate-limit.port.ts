export type RateLimitCheck = {
  key: string;
  windowSec: number;
  max: number;
};

export interface IRateLimitStore {
  consume(check: RateLimitCheck): Promise<{ allowed: boolean; retryAfterSec?: number }>;
}
