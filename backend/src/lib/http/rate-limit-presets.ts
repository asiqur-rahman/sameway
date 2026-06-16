import { NextRequest } from "next/server";

export type RateLimitOptions = {
  windowSec: number;
  max: number;
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
