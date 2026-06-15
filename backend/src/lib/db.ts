import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";
import { PrismaClient } from "@/generated/prisma/client";
import { env } from "@/lib/env";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
  pool: Pool | undefined;
};

function createPool() {
  return new Pool({
    connectionString: env.DATABASE_URL,
    ssl: env.DB_SSL ? { rejectUnauthorized: false } : undefined,
    max: env.DB_POOL_MAX,
    min: env.DB_POOL_MIN,
    idleTimeoutMillis: env.DB_POOL_IDLE_MS,
    connectionTimeoutMillis: env.DB_POOL_CONNECT_TIMEOUT_MS,
    allowExitOnIdle: env.NODE_ENV !== "production",
  });
}

export const pool = globalForPrisma.pool ?? createPool();

function createPrismaClient() {
  const adapter = new PrismaPg(pool);
  return new PrismaClient({ adapter });
}

export const db = globalForPrisma.prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.pool = pool;
  globalForPrisma.prisma = db;
}

export async function dbHealthCheck(): Promise<{ ok: boolean; latencyMs: number }> {
  const start = Date.now();
  try {
    await db.$queryRaw`SELECT 1`;
    return { ok: true, latencyMs: Date.now() - start };
  } catch {
    return { ok: false, latencyMs: Date.now() - start };
  }
}

export function poolStats() {
  return {
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount,
    max: env.DB_POOL_MAX,
  };
}
