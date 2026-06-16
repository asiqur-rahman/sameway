import { db } from "@/lib/db";
import { isFcmConfigured, sendPushToTokens } from "@/infrastructure/push/fcm.service";

export async function deliverPush(row: {
  id: string;
  userId: string;
  type: string;
  title: string;
  body: string;
  payload: unknown;
}): Promise<boolean> {
  const tokens = await db.deviceToken.findMany({
    where: { userId: row.userId },
    select: { token: true },
  });

  if (tokens.length === 0) {
    console.log(`[outbox] skip ${row.id} — no device tokens for user ${row.userId}`);
    return true;
  }

  const tokenList = tokens.map((t) => t.token);
  const data: Record<string, string> = {
    type: row.type,
    ...(typeof row.payload === "object" && row.payload !== null
      ? Object.fromEntries(
          Object.entries(row.payload as Record<string, unknown>).map(([k, v]) => [k, String(v)]),
        )
      : {}),
  };

  if (!isFcmConfigured()) {
    console.log(
      `[outbox] deliver ${row.type} → ${row.userId} (${tokenList.length} device(s), FCM not configured): ${row.title}`,
    );
    return true;
  }

  const { success, invalidTokens } = await sendPushToTokens(tokenList, {
    title: row.title,
    body: row.body,
    data,
  });

  if (invalidTokens.length > 0) {
    await db.deviceToken.deleteMany({ where: { token: { in: invalidTokens } } });
  }

  console.log(`[outbox] FCM ${row.type} → ${row.userId}: ${success}/${tokenList.length} sent`);
  return success > 0 || tokenList.length === 0;
}
