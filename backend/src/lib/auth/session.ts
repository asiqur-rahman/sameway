import { NextRequest } from "next/server";
import { Role } from "@/generated/prisma/client";
import { db } from "@/lib/db";
import { extractBearerToken, verifyAccessToken } from "@/lib/auth/jwt";
import { ForbiddenError, UnauthorizedError } from "@/lib/http/errors";

export type SessionUser = {
  id: string;
  role: Role;
  verificationStatus: string;
};

export async function getSession(request: NextRequest): Promise<SessionUser | null> {
  const token = extractBearerToken(request.headers.get("authorization"));
  if (!token) return null;

  try {
    const payload = await verifyAccessToken(token);
    const user = await db.user.findUnique({
      where: { id: payload.sub },
      select: { id: true, role: true, verificationStatus: true },
    });
    if (!user) return null;
    return user;
  } catch {
    return null;
  }
}

export async function requireAuth(request: NextRequest): Promise<SessionUser> {
  const session = await getSession(request);
  if (!session) throw new UnauthorizedError();
  return session;
}

export async function requireAdmin(request: NextRequest): Promise<SessionUser> {
  const session = await requireAuth(request);
  if (session.role !== Role.ADMIN) throw new ForbiddenError("Admin access required");
  return session;
}

export async function requireVerified(request: NextRequest): Promise<SessionUser> {
  const session = await requireAuth(request);
  if (session.verificationStatus !== "VERIFIED") {
    throw new ForbiddenError("Account verification required");
  }
  return session;
}
