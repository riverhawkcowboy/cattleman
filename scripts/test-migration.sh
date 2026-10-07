#!/usr/bin/env sh
set -eu

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL must point to a disposable PostgreSQL database." >&2
  exit 2
fi

psql "$DATABASE_URL" --set ON_ERROR_STOP=1 --file database/migrations/0001_init.sql
psql "$DATABASE_URL" --set ON_ERROR_STOP=1 --file database/tests/0001_init_smoke.sql
