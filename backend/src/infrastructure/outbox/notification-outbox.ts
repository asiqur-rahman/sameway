import type { NotificationType, Prisma } from "@/generated/prisma/client";
import { db } from "@/lib/db";

type NotifyInput = {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  payload?: Prisma.InputJsonValue;
};

/** Writes in-app notification + outbox row for async push workers. */
export async function notifyUser(input: NotifyInput) {
  return db.$transaction(async (tx) => {
    const notification = await tx.notification.create({
      data: {
        userId: input.userId,
        type: input.type,
        title: input.title,
        body: input.body,
        payload: input.payload,
      },
    });
    await tx.notificationOutbox.create({
      data: {
        userId: input.userId,
        type: input.type,
        title: input.title,
        body: input.body,
        payload: input.payload,
      },
    });
    return notification;
  });
}

export async function notifyMany(users: NotifyInput[]) {
  if (users.length === 0) return;
  await db.$transaction(async (tx) => {
    await tx.notification.createMany({
      data: users.map((u) => ({
        userId: u.userId,
        type: u.type,
        title: u.title,
        body: u.body,
        payload: u.payload,
      })),
    });
    await tx.notificationOutbox.createMany({
      data: users.map((u) => ({
        userId: u.userId,
        type: u.type,
        title: u.title,
        body: u.body,
        payload: u.payload,
      })),
    });
  });
}
