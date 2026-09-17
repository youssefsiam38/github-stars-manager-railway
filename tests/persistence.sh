#!/usr/bin/env bash
# shellcheck disable=SC2015
# Persistence: settings, categories and configs live in SQLite on the /app/data volume. Write a setting, take the
# stack down keeping the volume, bring it back, and confirm the setting survived. Standalone.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'compose logs --no-color --tail 100 || true; compose down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT

section "bring the stack up"
compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/health" 200 180 || die "app never became healthy"

section "before restart"
marker="persist_$(date +%s)"
assert_eq "a setting is written via PUT /api/settings" "200" \
  "$(auth_code PUT /api/settings "$(jq -nc --arg v "$marker" '{railway_persist_test:$v}')")"
assert_contains "the setting reads back" "$marker" "$(auth_get /api/settings)"

section "full restart (volume preserved)"
compose down >/dev/null 2>&1
compose up -d >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/health" 200 180 && pass "healthy again after restart" || die "not healthy after restart"

section "after restart"
assert_contains "the setting survived the restart (SQLite persisted)" "$marker" "$(auth_get /api/settings)"

summary
