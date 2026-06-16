import { NextResponse } from "next/server";
import { ZodError } from "zod";
import { AppError, ValidationError } from "./errors";
import {
  type ErrorLogContext,
  logServerError,
  normalizeError,
  sanitizeErrorForClient,
} from "./error-handler";

export type ApiSuccess<T> = {
  success: true;
  data: T;
  meta?: Record<string, unknown>;
};

export type ApiFailure = {
  success: false;
  error: {
    message: string;
    code?: string;
    details?: unknown;
  };
};

export function ok<T>(data: T, init?: ResponseInit, meta?: Record<string, unknown>) {
  const body: ApiSuccess<T> = { success: true, data, ...(meta ? { meta } : {}) };
  return NextResponse.json(body, { status: 200, ...init });
}

export function created<T>(data: T) {
  const body: ApiSuccess<T> = { success: true, data };
  return NextResponse.json(body, { status: 201 });
}

export function noContent() {
  return new NextResponse(null, { status: 204 });
}

export function fail(error: unknown, context?: ErrorLogContext): NextResponse<ApiFailure> {
  if (error instanceof ZodError) {
    return fail(new ValidationError(error.flatten()), context);
  }

  const original = error;
  const normalized = normalizeError(error);

  const shouldLog =
    !(original instanceof AppError) ||
    normalized.statusCode >= 500 ||
    isPrismaClientError(original);

  if (shouldLog) {
    logServerError(original, context);
  }

  const headers = new Headers();
  if (normalized.code === "RATE_LIMITED" && normalized.details && typeof normalized.details === "object") {
    const retry = (normalized.details as { retryAfterSec?: number }).retryAfterSec;
    if (retry) headers.set("Retry-After", String(retry));
  }

  const clientError = sanitizeErrorForClient(normalized);

  return NextResponse.json(
    { success: false, error: clientError },
    { status: normalized.statusCode, headers },
  );
}

/** True for Prisma client errors that should always be logged with meta. */
function isPrismaClientError(error: unknown): boolean {
  if (!(error instanceof Error)) return false;
  return error.name.startsWith("PrismaClient");
}
