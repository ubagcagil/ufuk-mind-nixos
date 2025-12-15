#!/usr/bin/env bash
set -euo pipefail

LANE="${1:-${LANE:-daily}}"

CONFIG="/etc/erpnext-backup.conf"
if [[ ! -f "$CONFIG" ]]; then
  echo "[erpnext-backup] Missing $CONFIG" >&2
  exit 1
fi
# shellcheck disable=SC1090
. "$CONFIG"

ERP_DIR="${ERP_DIR:-/srv/erpnext}"
COMPOSE_FILE="${COMPOSE_FILE:-pwd.yml}"
SERVICE="${SERVICE:-backend}"
SITE="${SITE:-frontend}"
BACKUP_DIR="${BACKUP_DIR:-/srv/erpnext-backups}"

# Lane -> default with_files
WITH_FILES="${WITH_FILES:-}"
if [[ -z "$WITH_FILES" ]]; then
  case "$LANE" in
    daily) WITH_FILES=0 ;;
    *)     WITH_FILES=1 ;;
  esac
fi

cd "$ERP_DIR"

mkdir -p "$BACKUP_DIR"
chgrp users "$BACKUP_DIR" 2>/dev/null || true
chmod 750 "$BACKUP_DIR" 2>/dev/null || true

echo "[erpnext-backup] $(date '+%F %T') lane=$LANE: bench backup (site=$SITE with_files=$WITH_FILES)"

if [[ "$WITH_FILES" == "1" ]]; then
  docker compose -f "$COMPOSE_FILE" exec -T "$SERVICE" bash -lc \
    "cd /home/frappe/frappe-bench && bench --site '$SITE' backup --with-files"
else
  docker compose -f "$COMPOSE_FILE" exec -T "$SERVICE" bash -lc \
    "cd /home/frappe/frappe-bench && bench --site '$SITE' backup"
fi

CID="$(docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE")"
if [[ -z "$CID" ]]; then
  echo "[erpnext-backup] ERROR: could not resolve container id for service=$SERVICE" >&2
  exit 1
fi

REMOTE_DIR="/home/frappe/frappe-bench/sites/$SITE/private/backups"
REMOTE_DB="$(docker exec "$CID" bash -lc "ls -1t $REMOTE_DIR/*-${SITE}-database.sql.gz 2>/dev/null | head -n1")"
if [[ -z "$REMOTE_DB" ]]; then
  echo "[erpnext-backup] ERROR: database backup not found in $REMOTE_DIR" >&2
  exit 1
fi

BASE="${REMOTE_DB%-database.sql.gz}"
REMOTE_CFG="${BASE}-site_config_backup.json"
REMOTE_FILES="${BASE}-files.tar"
REMOTE_PFILES="${BASE}-private-files.tar"

STAGE="$(mktemp -d -p "$BACKUP_DIR" ".stage-${LANE}-XXXXXX")"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

# Always: DB (and config if exists)
docker cp "$CID:$REMOTE_DB" "$STAGE/"
if docker exec "$CID" test -f "$REMOTE_CFG" >/dev/null 2>&1; then
  docker cp "$CID:$REMOTE_CFG" "$STAGE/"
fi

# Best-effort: file tarballs (do NOT fail service if missing)
if [[ "$WITH_FILES" == "1" ]]; then
  if docker exec "$CID" test -f "$REMOTE_FILES" >/dev/null 2>&1; then
    docker cp "$CID:$REMOTE_FILES" "$STAGE/"
  else
    echo "[erpnext-backup] WARN: public files tar not found: $REMOTE_FILES" >&2
  fi

  if docker exec "$CID" test -f "$REMOTE_PFILES" >/dev/null 2>&1; then
    docker cp "$CID:$REMOTE_PFILES" "$STAGE/"
  else
    echo "[erpnext-backup] WARN: private files tar not found: $REMOTE_PFILES" >&2
  fi
fi

OUT_DB="$BACKUP_DIR/erpnext-$LANE.sql.gz"
mv -f "$STAGE/$(basename "$REMOTE_DB")" "$OUT_DB"
gzip -t "$OUT_DB"

# Guard against the old “20-byte gz” style garbage
SIZE="$(stat -c%s "$OUT_DB" 2>/dev/null || echo 0)"
if [[ "$SIZE" -lt 200 ]]; then
  echo "[erpnext-backup] ERROR: backup too small ($SIZE bytes): $OUT_DB" >&2
  exit 1
fi

if [[ -f "$STAGE/$(basename "$REMOTE_CFG")" ]]; then
  mv -f "$STAGE/$(basename "$REMOTE_CFG")" "$BACKUP_DIR/erpnext-$LANE-site_config_backup.json"
fi
if [[ -f "$STAGE/$(basename "$REMOTE_FILES")" ]]; then
  mv -f "$STAGE/$(basename "$REMOTE_FILES")" "$BACKUP_DIR/erpnext-$LANE-files.tar"
fi
if [[ -f "$STAGE/$(basename "$REMOTE_PFILES")" ]]; then
  mv -f "$STAGE/$(basename "$REMOTE_PFILES")" "$BACKUP_DIR/erpnext-$LANE-private-files.tar"
fi

echo "[erpnext-backup] $(date '+%F %T') lane=$LANE: OK -> $OUT_DB"

