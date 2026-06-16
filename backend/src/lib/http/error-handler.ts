import { Prisma } from "@/generated/prisma/client";
import { env } from "@/lib/env";
import {
  AppError,
  ConflictError,
  NotFoundError,
  ServiceUnavailableError,
  ValidationError,
} from "./errors";

export type ErrorLogContext = {
  method?: string;
  path?: string;
  requestId?: string;
};

const isProd = env.NODE_ENV === "production";

/** Maps unknown failures to safe, client-facing AppError instances. */
export function normalizeError(error: unknown): AppError {
  if (error instanceof AppError) {
    return error;
  }

  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    return mapPrismaKnownError(error);
  }

  if (error instanceof Prisma.PrismaClientValidationError) {
    return new ValidationError({
      formErrors: ["Invalid request data"],
      fieldErrors: {},
    });
  }

  if (
    error instanceof Prisma.PrismaClientInitializationError ||
    error instanceof Prisma.PrismaClientRustPanicError
  ) {
    return new ServiceUnavailableError();
  }

  if (error instanceof SyntaxError) {
    return new ValidationError({
      formErrors: ["Invalid JSON body"],
      fieldErrors: {},
    });
  }

  // Never expose raw Error.message (may contain SQL, paths, secrets).
  return new AppError(500, "Internal server error", "INTERNAL_ERROR");
}

function mapPrismaKnownError(error: Prisma.PrismaClientKnownRequestError): AppError {
  switch (error.code) {
    case "P2002":
      return new ConflictError("A record with this value already exists");
    case "P2003":
      return new ConflictError("Related record does not exist");
    case "P2014":
      return new ValidationError({
        formErrors: ["Invalid relation in request"],
        fieldErrors: {},
      });
    case "P2025":
      return new NotFoundError("Resource");
    case "P1000":
    case "P1001":
    case "P1002":
    case "P1017":
      return new ServiceUnavailableError();
    default:
      return new AppError(500, "Internal server error", "INTERNAL_ERROR");
  }
}

/** Logs full error details server-side only. */
export function logServerError(error: unknown, context?: ErrorLogContext): void {
  const prefix = context?.path
    ? `[API Error] ${context.method ?? "?"} ${context.path}`
    : "[API Error]";

  if (error instanceof Error) {
    console.error(prefix, {
      name: error.name,
      message: error.message,
      stack: error.stack,
      ...(error instanceof Prisma.PrismaClientKnownRequestError
        ? { prismaCode: error.code, meta: error.meta }
        : {}),
      requestId: context?.requestId,
    });
    return;
  }

  console.error(prefix, error);
}

/** Strips sensitive details before serializing to the client. */
export function sanitizeErrorForClient(error: AppError): {
  message: string;
  code?: string;
  details?: unknown;
} {
  if (error.statusCode >= 500) {
    return {
      message: isProd ? "Internal server error" : error.message,
      code: error.code ?? "INTERNAL_ERROR",
    };
  }

  if (error.code === "SERVICE_UNAVAILABLE") {
    return {
      message: "Service temporarily unavailable. Please try again.",
      code: error.code,
    };
  }

  // Validation details are intentional for form UX.
  if (error.code === "VALIDATION_ERROR") {
    return {
      message: error.message,
      code: error.code,
      details: error.details,
    };
  }

  return {
    message: error.message,
    code: error.code,
    ...(error.details !== undefined && !isProd ? { details: error.details } : {}),
  };
}
