#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="${STACK_DIR:-/srv/erpnext}"
COMPOSE_FILE="${COMPOSE_FILE:-pwd.yml}"
SITE="${SITE:-frontend}"
BASE_URL="${BASE_URL:-http://localhost:8080}"

cd "$STACK_DIR"
DOCKER="/run/current-system/sw/bin/docker"
COMPOSE="$DOCKER compose -f $COMPOSE_FILE"

echo "== Containers =="
$COMPOSE ps

echo
echo "== Ping =="
curl -fsS "$BASE_URL/api/method/ping" || true

echo
echo "== HTTP status =="
curl -sSI "$BASE_URL" | head -n 1 || true

echo
echo "== bench doctor =="
$COMPOSE exec -T backend bench --site "$SITE" doctor || true

echo
echo "== Ensure scheduler enabled =="
$COMPOSE exec -T backend bench --site "$SITE" set-config enable_scheduler 1 || true
$COMPOSE exec -T backend bench --site "$SITE" enable-scheduler || true

