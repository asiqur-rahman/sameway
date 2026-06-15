import { apiRoute, parseBody } from "@/lib/http/api-route";
import { created, ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { sendMessageSchema } from "@/modules/chat/chat.schema";
import * as chatService from "@/modules/chat/chat.service";

export const GET = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
  const { id } = await params;
  const messages = await chatService.getMessages(id, session.id);
  return ok(messages);
});

export const POST = apiRoute(async (request, { params }) => {
  const session = await requireAuth(request);
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
