import { z } from "zod";

export const sendMessageSchema = z.object({
  body: z.string().min(1).max(2000),
});

export const createConversationSchema = z.object({
  rideId: z.string().optional(),
  participantIds: z.array(z.string()).min(1),
});
