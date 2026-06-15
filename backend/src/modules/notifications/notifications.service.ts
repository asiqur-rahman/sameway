import { db } from "@/lib/db";
import { paginate } from "@/lib/shared";

export async function listNotifications(userId: string, page = 1, limit = 30) {
  const { skip, take } = paginate(page, limit);
  const [items, total, unreadCount] = await Promise.all([
    db.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      skip,
      take,
    }),
    db.notification.count({ where: { userId } }),
    db.notification.count({ where: { userId, read: false } }),
  ]);
  return { items, total, unreadCount, page, limit };
}

export async function markRead(notificationId: string, userId: string) {
  return db.notification.updateMany({
    where: { id: notificationId, userId },
    data: { read: true },
  });
}

export async function markAllRead(userId: string) {
  await db.notification.updateMany({ where: { userId, read: false }, data: { read: true } });
  return { ok: true };
}
