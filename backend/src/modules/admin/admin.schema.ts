import { z } from "zod";

export const allowedDomainSchema = z.object({
  domain: z.string().min(3).max(100),
  autoVerify: z.boolean().default(false),
});

export const systemConfigSchema = z.object({
  maintenanceMode: z.boolean().optional(),
  autoVerifyKnownDomains: z.boolean().optional(),
});

export const userStatusSchema = z.object({
  verificationStatus: z.enum(["PENDING", "VERIFIED", "REJECTED"]).optional(),
  role: z.enum(["USER", "ADMIN"]).optional(),
});
