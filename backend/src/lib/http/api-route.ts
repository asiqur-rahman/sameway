import { NextRequest } from "next/server";
import { z, ZodSchema } from "zod";
import { ValidationError } from "./errors";
import { fail } from "./response";

export async function parseBody<T extends ZodSchema>(
  request: NextRequest,
  schema: T,
): Promise<z.infer<T>> {
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    throw new ValidationError({ formErrors: ["Invalid JSON body"], fieldErrors: {} });
  }
  const result = schema.safeParse(body);
  if (!result.success) {
    throw new ValidationError(result.error.flatten());
  }
  return result.data;
}

export function parseQuery<T extends ZodSchema>(
  request: NextRequest,
  schema: T,
): z.infer<T> {
  const params = Object.fromEntries(request.nextUrl.searchParams.entries());
  const result = schema.safeParse(params);
  if (!result.success) {
    throw new ValidationError(result.error.flatten());
  }
  return result.data;
}

type RouteContext = { params: Promise<Record<string, string>> };

type Handler = (
  request: NextRequest,
  context: RouteContext,
) => Promise<Response>;

export function apiRoute(handler: Handler): Handler {
  return async (request, context) => {
    try {
      return await handler(request, context);
    } catch (error) {
      return fail(error);
    }
  };
}
