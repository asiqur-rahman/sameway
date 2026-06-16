import { env } from "@/lib/env";

type FcmMessage = {
  title: string;
  body: string;
  data?: Record<string, string>;
};

let messaging: import("firebase-admin/messaging").Messaging | null = null;

function initFirebase() {
  if (messaging) return messaging;
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    return null;
  }

  const admin = require("firebase-admin") as typeof import("firebase-admin");
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.FIREBASE_PROJECT_ID,
        clientEmail: env.FIREBASE_CLIENT_EMAIL,
        privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
      }),
    });
  }
  messaging = admin.messaging();
  return messaging;
}

export function isFcmConfigured(): boolean {
  return Boolean(env.FIREBASE_PROJECT_ID && env.FIREBASE_CLIENT_EMAIL && env.FIREBASE_PRIVATE_KEY);
}

export async function sendPushToTokens(
  tokens: string[],
  message: FcmMessage,
): Promise<{ success: number; invalidTokens: string[] }> {
  const fcm = initFirebase();
  if (!fcm || tokens.length === 0) {
    return { success: 0, invalidTokens: [] };
  }

  const res = await fcm.sendEachForMulticast({
    tokens,
    notification: { title: message.title, body: message.body },
    data: message.data,
    android: { priority: "high" },
    apns: { payload: { aps: { sound: "default" } } },
  });

  const invalidTokens: string[] = [];
  res.responses.forEach((r, i) => {
    if (!r.success) {
      const code = r.error?.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token"
      ) {
        invalidTokens.push(tokens[i]);
      }
    }
  });

  return { success: res.successCount, invalidTokens };
}
