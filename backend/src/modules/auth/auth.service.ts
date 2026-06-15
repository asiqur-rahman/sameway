import { randomUUID } from "crypto";
import { db } from "@/lib/db";
import { hashPassword, verifyPassword } from "@/lib/auth/password";
import { signAccessToken, signRefreshToken } from "@/lib/auth/jwt";
import { ConflictError, ForbiddenError, UnauthorizedError } from "@/lib/http/errors";
import { omitPassword } from "@/lib/shared";
import type { SigninInput, SignupInput } from "./auth.schema";

function extractDomain(email: string): string {
  return email.split("@")[1]?.toLowerCase() ?? "";
}

async function assertSignupAllowed() {
  const config = await db.systemConfig.findUnique({ where: { id: "default" } });
  if (config?.maintenanceMode) {
    throw new ForbiddenError("Signups are disabled during maintenance");
  }
}

async function resolveVerification(domain: string) {
  const allowed = await db.allowedDomain.findUnique({ where: { domain } });
  const config = await db.systemConfig.findUnique({ where: { id: "default" } });
  const autoVerify =
    allowed?.autoVerify === true ||
    (config?.autoVerifyKnownDomains && allowed !== null);

  return {
    verificationStatus: autoVerify ? ("VERIFIED" as const) : ("PENDING" as const),
    companyDomain: domain,
  };
}

export async function signup(input: SignupInput) {
  await assertSignupAllowed();

  const domain = extractDomain(input.workEmail);
  const allowed = await db.allowedDomain.findUnique({ where: { domain } });
  if (!allowed) {
    throw new ForbiddenError(`Email domain @${domain} is not allowed`);
  }

  const existing = await db.user.findFirst({
    where: { OR: [{ workEmail: input.workEmail }, { phone: input.phone }] },
  });
  if (existing) throw new ConflictError("Email or phone already registered");

  const { verificationStatus, companyDomain } = await resolveVerification(domain);
  const passwordHash = await hashPassword(input.password);

  const user = await db.user.create({
    data: {
      fullName: input.fullName,
      workEmail: input.workEmail,
      phone: input.phone,
      passwordHash,
      companyDomain,
      verificationStatus,
      workEmailVerified: true,
      reminderSettings: { create: {} },
    },
  });

  const tokens = await issueTokens(user.id, user.role);
  return { user: omitPassword(user), tokens };
}

export async function signin(input: SigninInput) {
  const user = await db.user.findUnique({ where: { workEmail: input.workEmail } });
  if (!user) throw new UnauthorizedError("Invalid credentials");

  const valid = await verifyPassword(input.password, user.passwordHash);
  if (!valid) throw new UnauthorizedError("Invalid credentials");

  const tokens = await issueTokens(user.id, user.role);
  return { user: omitPassword(user), tokens };
}

export async function refresh(refreshToken: string) {
  const { verifyRefreshToken } = await import("@/lib/auth/jwt");
  const payload = await verifyRefreshToken(refreshToken);

  const stored = await db.refreshToken.findUnique({ where: { token: payload.jti } });
  if (!stored || stored.expiresAt < new Date()) {
    throw new UnauthorizedError("Refresh token expired");
  }

  await db.refreshToken.delete({ where: { id: stored.id } });

  const user = await db.user.findUnique({ where: { id: payload.sub } });
  if (!user) throw new UnauthorizedError("User not found");

  const tokens = await issueTokens(user.id, user.role);
  return { user: omitPassword(user), tokens };
}

export async function logout(refreshToken: string) {
  try {
    const { verifyRefreshToken } = await import("@/lib/auth/jwt");
    const payload = await verifyRefreshToken(refreshToken);
    await db.refreshToken.deleteMany({ where: { token: payload.jti } });
  } catch {
    // ignore invalid tokens on logout
  }
}

async function issueTokens(userId: string, role: string) {
  const jti = randomUUID();
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

  await db.refreshToken.create({
    data: { token: jti, userId, expiresAt },
  });

  const [accessToken, refreshToken] = await Promise.all([
    signAccessToken(userId, role),
    signRefreshToken(userId, jti),
  ]);

  return { accessToken, refreshToken };
}

export async function getMe(userId: string) {
  const user = await db.user.findUnique({
    where: { id: userId },
    include: {
      vehicles: true,
      places: true,
      reminderSettings: true,
    },
  });
  if (!user) throw new UnauthorizedError("User not found");
  return omitPassword(user);
}
