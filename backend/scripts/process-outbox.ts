/**
 * Polls NotificationOutbox and delivers push notifications via FCM.
 * Run via: npm run outbox:process
 */
import "dotenv/config";
import { db } from "../src/lib/db";
import { deliverPush } from "../src/infrastructure/push/deliver-push";

const BATCH_SIZE = 50;
const MAX_ATTEMPTS = 3;

async function processBatch(): Promise<number> {
  const pending = await db.notificationOutbox.findMany({
    where: { status: "PENDING", attempts: { lt: MAX_ATTEMPTS } },
    orderBy: { createdAt: "asc" },
    take: BATCH_SIZE,
  });

  if (pending.length === 0) return 0;

  for (const row of pending) {
    try {
      const ok = await deliverPush({
        id: row.id,
        userId: row.userId,
        type: row.type,
        title: row.title,
        body: row.body,
        payload: row.payload,
      });
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
