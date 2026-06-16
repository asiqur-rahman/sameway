import { z } from "zod";
import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created, ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { env } from "@/lib/env";
import { checkRateLimit, RateLimits } from "@/lib/http/rate-limit";
import { sendMessageSchema } from "@/modules/chat/chat.schema";
import * as chatService from "@/modules/chat/chat.service";

const messagesQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(200).optional(),
});

export const GET = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const query = messagesQuerySchema.parse(
    Object.fromEntries(request.nextUrl.searchParams.entries()),
  );
  const messages = await chatService.getMessages(id, session.id, {
    limit: query.limit,
  });
  return ok(messages);
});

export const POST = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  if (env.RATE_LIMIT_ENABLED) {
    await checkRateLimit(request, {
      ...RateLimits.chatSend(session.id),
      key: () => `user:${session.id}:chat`,
    });
  }
  const { id } = await params;
  const body = await parseBody(request, sendMessageSchema);
  const message = await chatService.sendMessage(id, session.id, body);
  return created(message);
});

export const PATCH = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const result = await chatService.markConversationRead(id, session.id);
  return ok(result);
});
