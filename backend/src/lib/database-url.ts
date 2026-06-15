/**
 * Build a PostgreSQL connection URL from DB_* env vars.
 * DATABASE_URL takes precedence when set directly.
 */
export function buildDatabaseUrl(): string {
  if (process.env.DATABASE_URL) {
    return process.env.DATABASE_URL;
  }

  const host = process.env.DB_HOST ?? "localhost";
  const port = process.env.DB_PORT ?? "5432";
  const username = process.env.DB_USERNAME ?? "postgres";
  const password = process.env.DB_PASSWORD ?? "";
  const name = process.env.DB_NAME ?? "sameway";
  const ssl = process.env.DB_SSL === "true";

  const user = encodeURIComponent(username);
  const pass = encodeURIComponent(password);
  const params = ssl ? "sslmode=require" : "schema=public";

  return `postgresql://${user}:${pass}@${host}:${port}/${name}?${params}`;
}
