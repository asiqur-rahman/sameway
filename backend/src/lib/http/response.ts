import { NextResponse } from "next/server";
import { ZodError } from "zod";
import { AppError, ValidationError } from "./errors";

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

export function fail(error: unknown): NextResponse<ApiFailure> {
  if (error instanceof AppError) {
    return NextResponse.json(
      {
        success: false,
        error: {
          message: error.message,
          code: error.code,
          details: error.details,
        },
      },
      { status: error.statusCode },
    );
  }

  if (error instanceof ZodError) {
    const validation = new ValidationError(error.flatten());
    return fail(validation);
  }

  console.error("[API Error]", error);
  return NextResponse.json(
    {
      success: false,
      error: { message: "Internal server error", code: "INTERNAL_ERROR" },
    },
    { status: 500 },
  );
}
