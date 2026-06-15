import { SignJWT, jwtVerify } from "jose";
import { env } from "@/lib/env";

const accessSecret = new TextEncoder().encode(env.JWT_ACCESS_SECRET);
const refreshSecret = new TextEncoder().encode(env.JWT_REFRESH_SECRET);

export type AccessTokenPayload = {
  sub: string;
  role: string;
  type: "access";
};

export type RefreshTokenPayload = {
  sub: string;
  type: "refresh";
  jti: string;
};

export async function signAccessToken(userId: string, role: string): Promise<string> {
  return new SignJWT({ role, type: "access" })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(userId)
    .setIssuedAt()
    .setExpirationTime(env.JWT_ACCESS_EXPIRES_IN)
    .sign(accessSecret);
}

export async function signRefreshToken(userId: string, jti: string): Promise<string> {
  return new SignJWT({ type: "refresh", jti })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(userId)
    .setIssuedAt()
    .setExpirationTime(env.JWT_REFRESH_EXPIRES_IN)
    .sign(refreshSecret);
}

export async function verifyAccessToken(token: string): Promise<AccessTokenPayload & { sub: string }> {
  const { payload } = await jwtVerify(token, accessSecret);
  if (payload.type !== "access" || !payload.sub) {
    throw new Error("Invalid access token");
  }
  return payload as AccessTokenPayload & { sub: string };
}

export async function verifyRefreshToken(token: string): Promise<RefreshTokenPayload & { sub: string }> {
  const { payload } = await jwtVerify(token, refreshSecret);
  if (payload.type !== "refresh" || !payload.sub || !payload.jti) {
    throw new Error("Invalid refresh token");
  }
  return payload as RefreshTokenPayload & { sub: string };
}

export function extractBearerToken(authHeader: string | null): string | null {
  if (!authHeader?.startsWith("Bearer ")) return null;
  return authHeader.slice(7).trim() || null;
}
