export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
    public readonly code?: string,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = "AppError";
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Unauthorized") {
    super(401, message, "UNAUTHORIZED");
  }
}

export class ForbiddenError extends AppError {
  constructor(message = "Forbidden") {
    super(403, message, "FORBIDDEN");
  }
}

export class NotFoundError extends AppError {
  constructor(resource = "Resource") {
    super(404, `${resource} not found`, "NOT_FOUND");
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(409, message, "CONFLICT");
  }
}

export class ValidationError extends AppError {
  constructor(details: unknown) {
    super(400, "Validation failed", "VALIDATION_ERROR", details);
  }
}

export class MaintenanceError extends AppError {
  constructor() {
    super(503, "Service temporarily unavailable", "MAINTENANCE_MODE");
  }
}

export class TooManyRequestsError extends AppError {
  constructor(retryAfterSec: number) {
    super(429, "Too many requests", "RATE_LIMITED", { retryAfterSec });
  }
}

export class ServiceUnavailableError extends AppError {
  constructor(message = "Service temporarily unavailable") {
    super(503, message, "SERVICE_UNAVAILABLE");
  }
}

export class InternalServerError extends AppError {
  constructor() {
    super(500, "Internal server error", "INTERNAL_ERROR");
  }
}
