#!/bin/sh
set -e

wait_for_db() {
  if [ -z "$DB_HOST" ]; then
    return 0
  fi
  echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT:-5432}..."
  until pg_isready -h "$DB_HOST" -p "${DB_PORT:-5432}" -U "${DB_USERNAME:-postgres}" > /dev/null 2>&1; do
    sleep 1
  done
  echo "PostgreSQL is ready."
}

run_db_push() {
  if [ "${RUN_DB_PUSH:-true}" != "true" ]; then
    return 0
  fi
  echo "Applying database schema..."
  if [ -x "./node_modules/.bin/prisma" ]; then
    ./node_modules/.bin/prisma db push --skip-generate
  elif command -v npx > /dev/null 2>&1; then
    npx prisma db push --skip-generate
  else
    echo "Prisma CLI not found — skip db push"
  fi
}

run_seed() {
  if [ "${SEED_DB:-false}" != "true" ]; then
    return 0
  fi
  echo "Seeding database..."
  if [ -x "./node_modules/.bin/tsx" ]; then
    ./node_modules/.bin/tsx prisma/seed.ts
  else
    npm run db:seed
  fi
}

if [ "$1" = "setup" ]; then
  wait_for_db
  run_db_push
  run_seed
  echo "Database setup complete."
  exit 0
fi

if [ "$1" = "outbox-loop" ]; then
  wait_for_db
  echo "Starting notification outbox worker (poll every ${OUTBOX_POLL_SEC:-30}s)..."
  while true; do
    if [ -x "./node_modules/.bin/tsx" ]; then
      ./node_modules/.bin/tsx scripts/process-outbox.ts || true
    else
      npm run outbox:process || true
    fi
    sleep "${OUTBOX_POLL_SEC:-30}"
  done
fi

wait_for_db
run_db_push
echo "Starting API on port ${PORT:-3000}..."
exec "$@"
