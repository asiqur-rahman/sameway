import { NextRequest, NextResponse } from "next/server";
import { TooManyRequestsError } from "@/lib/http/errors";
import { checkEdgeRateLimit } from "@/lib/http/rate-limit-edge";
import { ipKey, RateLimits } from "@/lib/http/rate-limit-presets";

function corsOrigins(): string[] {
  return (process.env.CORS_ORIGINS ?? "http://localhost:7357,http://localhost:3000")
    .split(",")
    .map((o) => o.trim());
}

function rateLimitEnabled(): boolean {
  return process.env.RATE_LIMIT_ENABLED !== "false";
}

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

async function applyRateLimit(request: NextRequest): Promise<void> {
  if (!rateLimitEnabled()) return;

  const path = request.nextUrl.pathname;

  if (path.endsWith("/auth/signup") && request.method === "POST") {
    await checkEdgeRateLimit(request, RateLimits.signup);
    return;
  }
  if (path.endsWith("/auth/signin") && request.method === "POST") {
    await checkEdgeRateLimit(request, RateLimits.auth);
    return;
  }
  if (path.endsWith("/auth/refresh") && request.method === "POST") {
    await checkEdgeRateLimit(request, RateLimits.auth);
    return;
  }
  if (path.endsWith("/rides/search") && request.method === "POST") {
    await checkEdgeRateLimit(request, RateLimits.search);
    return;
  }

  if (request.method !== "GET" && request.method !== "HEAD" && request.method !== "OPTIONS") {
    await checkEdgeRateLimit(request, {
      ...RateLimits.general,
      key: (r) => ipKey(r, "write"),
    });
  }
}

export async function proxy(request: NextRequest) {
  if (!request.nextUrl.pathname.startsWith("/api")) {
    return NextResponse.next();
  }

  const origin = request.headers.get("origin");
  const headers = new Headers();
  const allowedOrigins = corsOrigins();

  if (origin && allowedOrigins.includes(origin)) {
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
    await applyRateLimit(request);
  } catch (error) {
    if (error instanceof TooManyRequestsError) {
      const res = rateLimitResponse(error);
      headers.forEach((value, key) => res.headers.set(key, value));
      return res;
    }
    console.error("[Proxy Error]", error);
    const res = NextResponse.json(
      { success: false, error: { message: "Internal server error", code: "INTERNAL_ERROR" } },
      { status: 500 },
    );
    headers.forEach((value, key) => res.headers.set(key, value));
    return res;
  }

  const response = NextResponse.next();
  headers.forEach((value, key) => response.headers.set(key, value));
  return response;
}

export const config = {
  matcher: "/api/:path*",
};
