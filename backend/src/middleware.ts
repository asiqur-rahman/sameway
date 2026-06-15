import { NextRequest, NextResponse } from "next/server";
import { corsOrigins, env } from "@/lib/env";
import { TooManyRequestsError } from "@/lib/http/errors";
import { checkRateLimit, ipKey, RateLimits } from "@/lib/http/rate-limit";

function rateLimitResponse(error: TooManyRequestsError): NextResponse {
  const retry =
    error.details && typeof error.details === "object"
      ? (error.details as { retryAfterSec?: number }).retryAfterSec
      : 60;
  const headers = new Headers({ "Retry-After": String(retry ?? 60) });
  return NextResponse.json(
    {
      success: false,
      error: { message: error.message, code: error.code, details: error.details },
    },
    { status: 429, headers },
  );
}

function applyRateLimit(request: NextRequest): void {
  if (!env.RATE_LIMIT_ENABLED) return;

  const path = request.nextUrl.pathname;

  if (path.endsWith("/auth/signup") && request.method === "POST") {
    checkRateLimit(request, RateLimits.signup);
    return;
  }
  if (path.endsWith("/auth/signin") && request.method === "POST") {
    checkRateLimit(request, RateLimits.auth);
    return;
  }
  if (path.endsWith("/auth/refresh") && request.method === "POST") {
    checkRateLimit(request, RateLimits.auth);
    return;
  }
  if (path.endsWith("/rides/search") && request.method === "POST") {
    checkRateLimit(request, RateLimits.search);
    return;
  }

  if (request.method !== "GET" && request.method !== "HEAD" && request.method !== "OPTIONS") {
    checkRateLimit(request, {
      ...RateLimits.general,
      key: (r) => ipKey(r, "write"),
    });
  }
}

export function middleware(request: NextRequest) {
  if (!request.nextUrl.pathname.startsWith("/api")) {
    return NextResponse.next();
  }

  const origin = request.headers.get("origin");
  const headers = new Headers();

  if (origin && corsOrigins.includes(origin)) {
    headers.set("Access-Control-Allow-Origin", origin);
    headers.set("Access-Control-Allow-Credentials", "true");
  }

  headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
  headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  headers.set("X-Content-Type-Options", "nosniff");

  if (request.method === "OPTIONS") {
    return new NextResponse(null, { status: 204, headers });
  }

  try {
    applyRateLimit(request);
  } catch (error) {
    if (error instanceof TooManyRequestsError) {
      const res = rateLimitResponse(error);
      headers.forEach((value, key) => res.headers.set(key, value));
      return res;
    }
    throw error;
  }

  const response = NextResponse.next();
  headers.forEach((value, key) => response.headers.set(key, value));
  return response;
}

export const config = {
  matcher: "/api/:path*",
};
