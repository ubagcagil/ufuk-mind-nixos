#!/usr/bin/env bash
set -euo pipefail

LANE="${1:-daily}"

STACK_DIR="${STACK_DIR:-/srv/erpnext}"
COMPOSE_FILE="${COMPOSE_FILE:-pwd.yml}"
SITE="${SITE:-frontend}"
BACKEND_SERVICE="${BACKEND_SERVICE:-backend}"
OUT_DIR="${OUT_DIR:-/srv/erpnext-backups}"

WITH_FILES=0
if [[ "$LANE" != "daily" ]]; then
  WITH_FILES=1
fi

ts() { date '+%F %T'; }

cd "$STACK_DIR"

CID="$(docker compose -f "$COMPOSE_FILE" ps -q "$BACKEND_SERVICE" || true)"
if [[ -z "$CID" ]]; then
  echo "[erpnext-backup] $(ts) ERROR: backend container not found" >&2
  exit 1
fi


echo "[erpnext-backup] $(ts) lane=$LANE: bench backup (site=$SITE with_files=$WITH_FILES)"

if [[ "$WITH_FILES" -eq 1 ]]; then
  docker compose -f "$COMPOSE_FILE" exec -T "$BACKEND_SERVICE" bash -lc \
    "cd /home/frappe/frappe-bench && bench --site \"$SITE\" backup --with-files"
else
  docker compose -f "$COMPOSE_FILE" exec -T "$BACKEND_SERVICE" bash -lc \
    "cd /home/frappe/frappe-bench && bench --site \"$SITE\" backup"
fi

SQL_IN="$(docker compose -f "$COMPOSE_FILE" exec -T "$BACKEND_SERVICE" bash -lc \
  "ls -1t /home/frappe/frappe-bench/sites/$SITE/private/backups/*.sql.gz 2>/dev/null | head -n 1" || true)"
[[ -n "$SQL_IN" ]] || { echo "[erpnext-backup] $(ts) ERROR: sql backup not found" >&2; exit 1; }

PUB_IN=""
PRIV_IN=""
if [[ "$WITH_FILES" -eq 1 ]]; then
  PUB_IN="$(docker compose -f "$COMPOSE_FILE" exec -T "$BACKEND_SERVICE" bash -lc \
    "ls -1t /home/frappe/frappe-bench/sites/$SITE/private/backups/*public-files*.tar* 2>/dev/null | head -n 1" || true)"
  PRIV_IN="$(docker compose -f "$COMPOSE_FILE" exec -T "$BACKEND_SERVICE" bash -lc \
    "ls -1t /home/frappe/frappe-bench/sites/$SITE/private/backups/*private-files*.tar* 2>/dev/null | head -n 1" || true)"
  [[ -n "$PUB_IN" && -n "$PRIV_IN" ]] || { echo "[erpnext-backup] $(ts) ERROR: file backups not found" >&2; exit 1; }
fi

mkdir -p "$OUT_DIR"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

docker cp "${CID}:${SQL_IN}" "$TMP_DIR/db.sql.gz"
test -s "$TMP_DIR/db.sql.gz"

if [[ "$WITH_FILES" -eq 1 ]]; then
  docker cp "${CID}:${PUB_IN}"  "$TMP_DIR/public-files.tar"
  docker cp "${CID}:${PRIV_IN}" "$TMP_DIR/private-files.tar"
  test -s "$TMP_DIR/public-files.tar"
  test -s "$TMP_DIR/private-files.tar"
fi

if [[ "$WITH_FILES" -eq 0 ]]; then
  OUT="$OUT_DIR/erpnext-${LANE}.sql.gz"
  cp "$TMP_DIR/db.sql.gz" "${OUT}.tmp"
  mv "${OUT}.tmp" "$OUT"
else
  OUT="$OUT_DIR/erpnext-${LANE}.tgz"
  tar -C "$TMP_DIR" -czf "${OUT}.tmp" db.sql.gz public-files.tar private-files.tar
  mv "${OUT}.tmp" "$OUT"
fi

echo "[erpnext-backup] $(ts) lane=$LANE: OK -> $OUT"


