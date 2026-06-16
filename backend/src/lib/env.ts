import { z } from "zod";
import { buildDatabaseUrl } from "./database-url";

// Ensure Prisma and pg use the same URL when only DB_* vars are set.
process.env.DATABASE_URL ??= buildDatabaseUrl();

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  DB_HOST: z.string().default("localhost"),
  DB_PORT: z.coerce.number().default(5432),
  DB_USERNAME: z.string().default("postgres"),
  DB_PASSWORD: z.string().default(""),
  DB_NAME: z.string().default("sameway"),
  DB_SSL: z
    .enum(["true", "false"])
    .default("false")
    .transform((v) => v === "true"),
  DATABASE_URL: z.string().min(1),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  JWT_ACCESS_EXPIRES_IN: z.string().default("15m"),
  JWT_REFRESH_EXPIRES_IN: z.string().default("7d"),
  CORS_ORIGINS: z.string().default("http://localhost:7357,http://localhost:3000"),
  UPLOAD_DIR: z.string().default("./uploads"),
  MAX_UPLOAD_SIZE_MB: z.coerce.number().default(5),
  GOOGLE_MAPS_API_KEY: z.string().optional(),
  APP_URL: z.string().default("http://localhost:3000"),
  DB_POOL_MAX: z.coerce.number().int().min(1).max(200).default(25),
  DB_POOL_MIN: z.coerce.number().int().min(0).max(50).default(2),
  DB_POOL_IDLE_MS: z.coerce.number().int().min(1000).default(30_000),
  DB_POOL_CONNECT_TIMEOUT_MS: z.coerce.number().int().min(1000).default(5000),
  SEARCH_CANDIDATE_CAP: z.coerce.number().int().min(50).max(1000).default(300),
  SEARCH_CACHE_TTL_SEC: z.coerce.number().int().min(0).max(300).default(30),
  SEARCH_BBOX_BUFFER_KM: z.coerce.number().min(5).max(50).default(18),
  RATE_LIMIT_ENABLED: z
    .enum(["true", "false"])
    .default("true")
    .transform((v) => v === "true"),
  REDIS_URL: z.string().url().optional(),
  GEOCODE_CACHE_TTL_SEC: z.coerce.number().int().min(60).max(604_800).default(86_400),
  CACHE_MAX_ENTRIES: z.coerce.number().int().min(1000).max(500_000).default(20_000),
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
});

function loadEnv() {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const formatted = parsed.error.issues
      .map((issue) => `  ${issue.path.join(".")}: ${issue.message}`)
      .join("\n");
    throw new Error(`Invalid environment variables:\n${formatted}`);
  }
  return parsed.data;
}

export const env = loadEnv();

export const corsOrigins = env.CORS_ORIGINS.split(",").map((o) => o.trim());
