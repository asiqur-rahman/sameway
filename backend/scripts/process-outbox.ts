/**
 * Polls NotificationOutbox and delivers push notifications.
 * Run via: npm run outbox:process
 *
 * Wire FCM/APNs in deliverPush() for production.
 */
import "dotenv/config";
import { db } from "../src/lib/db";

const BATCH_SIZE = 50;

async function deliverPush(row: {
  id: string;
  userId: string;
  type: string;
  title: string;
  body: string;
}): Promise<boolean> {
  const tokens = await db.deviceToken.findMany({
    where: { userId: row.userId },
    select: { token: true, platform: true },
  });

  if (tokens.length === 0) {
    console.log(`[outbox] skip ${row.id} — no device tokens for user ${row.userId}`);
    return true;
  }

  // TODO: integrate FCM/APNs using tokens
  console.log(
    `[outbox] deliver ${row.type} → ${row.userId} (${tokens.length} device(s)): ${row.title}`,
  );
  return true;
}

async function processBatch(): Promise<number> {
  const pending = await db.notificationOutbox.findMany({
    where: { status: "PENDING" },
    orderBy: { createdAt: "asc" },
    take: BATCH_SIZE,
  });

  if (pending.length === 0) return 0;

  for (const row of pending) {
    try {
      const ok = await deliverPush(row);
      await db.notificationOutbox.update({
        where: { id: row.id },
        data: {
          status: ok ? "SENT" : "FAILED",
          processedAt: new Date(),
          attempts: { increment: 1 },
        },
      });
    } catch (err) {
      console.error(`[outbox] failed ${row.id}:`, err);
      await db.notificationOutbox.update({
        where: { id: row.id },
        data: {
          status: "FAILED",
          processedAt: new Date(),
          attempts: { increment: 1 },
        },
      });
    }
  }

  return pending.length;
}

async function main() {
  const processed = await processBatch();
  console.log(`[outbox] processed ${processed} row(s)`);
  await db.$disconnect();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
