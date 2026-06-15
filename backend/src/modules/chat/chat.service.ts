import { NotificationType } from "@/generated/prisma/client";
import { db } from "@/lib/db";
import { ForbiddenError, NotFoundError } from "@/lib/http/errors";
import type { sendMessageSchema } from "./chat.schema";
import type { z } from "zod";

export async function listConversations(userId: string) {
  const participations = await db.conversationParticipant.findMany({
    where: { userId },
    include: {
      conversation: {
        include: {
          messages: { orderBy: { sentAt: "desc" }, take: 1 },
          participants: {
            include: { user: { select: { id: true, fullName: true, photoUrl: true } } },
          },
          ride: { select: { id: true, startAddress: true, endAddress: true, departureAt: true } },
        },
      },
    },
    orderBy: { conversation: { updatedAt: "desc" } },
  });

  return participations.map((p) => p.conversation);
}

export async function getMessages(conversationId: string, userId: string) {
  const participant = await db.conversationParticipant.findUnique({
    where: { conversationId_userId: { conversationId, userId } },
  });
  if (!participant) throw new ForbiddenError("Not a participant");

  return db.message.findMany({
    where: { conversationId },
    orderBy: { sentAt: "asc" },
    include: { sender: { select: { id: true, fullName: true, photoUrl: true } } },
  });
}

export async function sendMessage(
  conversationId: string,
  senderId: string,
  input: z.infer<typeof sendMessageSchema>,
) {
  const participant = await db.conversationParticipant.findUnique({
    where: { conversationId_userId: { conversationId, userId: senderId } },
  });
  if (!participant) throw new ForbiddenError("Not a participant");

  const message = await db.$transaction(async (tx) => {
    const msg = await tx.message.create({
      data: { conversationId, senderId, body: input.body },
      include: { sender: { select: { id: true, fullName: true, photoUrl: true } } },
    });
    await tx.conversation.update({ where: { id: conversationId }, data: { updatedAt: new Date() } });

    const others = await tx.conversationParticipant.findMany({
      where: { conversationId, userId: { not: senderId } },
    });
    await tx.notification.createMany({
      data: others.map((o) => ({
        userId: o.userId,
        type: NotificationType.MESSAGE,
        title: "New message",
        body: input.body.slice(0, 100),
        payload: { conversationId, messageId: msg.id },
      })),
    });

    return msg;
  });

  return message;
}

export async function markConversationRead(conversationId: string, userId: string) {
  await db.message.updateMany({
    where: { conversationId, senderId: { not: userId }, readAt: null },
    data: { readAt: new Date() },
  });
  return { ok: true };
}
