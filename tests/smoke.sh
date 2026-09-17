#!/usr/bin/env bash
# shellcheck disable=SC2015
# Smoke test: run the app, then verify liveness, that the SPA is served, that the API requires the bearer secret,
# and that an authenticated API call works.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"

STARTED=0
if [ "${GSM_REUSE_STACK:-0}" != "1" ]; then
  section "bring the stack up"
  compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
  STARTED=1
  trap 'compose logs --no-color --tail 100 || true; [ "$STARTED" = 1 ] && compose down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT
else
  trap 'rm -rf "$TEST_TMP"' EXIT
fi

section "liveness"
wait_for_code "$APP_URL/health" 200 180 && pass "/health returns 200 (no auth)" || die "app never became healthy"
assert_eq "the SPA is served at /" "200" "$(http_code "$APP_URL/")"
assert_eq "/api/health is reachable without a secret" "200" "$(http_code "$APP_URL/api/health")"

section "the API requires the bearer secret"
assert_eq "GET /api/settings without a secret is rejected" "401" "$(http_code "$APP_URL/api/settings")"
assert_eq "GET /api/settings with a wrong secret is rejected" "401" \
  "$(http_code "$APP_URL/api/settings" -H 'Authorization: Bearer definitely-wrong')"

section "an authenticated API call works"
assert_eq "GET /api/settings with the secret works" "200" "$(auth_code GET /api/settings)"
assert_eq "GET /api/categories with the secret works" "200" "$(auth_code GET /api/categories)"

summary
