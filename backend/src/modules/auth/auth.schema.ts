import { z } from "zod";

export const signupSchema = z.object({
  fullName: z.string().min(2).max(100),
  workEmail: z.email(),
  phone: z.string().min(10).max(20),
  password: z.string().min(8).max(128),
});

export const signinSchema = z.object({
  workEmail: z.email(),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export type SignupInput = z.infer<typeof signupSchema>;
export type SigninInput = z.infer<typeof signinSchema>;
