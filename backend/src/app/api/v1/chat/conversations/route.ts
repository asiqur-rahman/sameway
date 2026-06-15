import { apiRoute } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import * as chatService from "@/modules/chat/chat.service";

export const GET = apiRoute(async (request) => {
  const session = await requireAuth(request);
  const conversations = await chatService.listConversations(session.id);
  return ok(conversations);
});
