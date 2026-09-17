#!/usr/bin/env bash
# shellcheck disable=SC2015
# Live test of a deployed template: the flows the local smoke covers, over HTTPS.
#
#   API_SECRET_FILE=./api-secret tests/railway-smoke.sh https://<app-domain>
#
# The API secret is read from a file (never an argument, never printed).
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
[ $# -ge 1 ] || { sed -n '3,6p' "$0"; exit 2; }
APP_URL=${1%/}; export APP_URL
: "${API_SECRET_FILE:?set API_SECRET_FILE}"
GSM_SECRET=$(tr -d '\n' < "$API_SECRET_FILE"); export GSM_SECRET
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'rm -rf "$TEST_TMP"' EXIT

section "availability over HTTPS"
wait_for_code "$APP_URL/health" 200 300 && pass "/health returns 200 over HTTPS" || die "not healthy"
assert_eq "the SPA is served at /" "200" "$(http_code "$APP_URL/")"

section "the API requires the bearer secret over HTTPS"
assert_eq "GET /api/settings without a secret is rejected" "401" "$(http_code "$APP_URL/api/settings")"
assert_eq "GET /api/settings with a wrong secret is rejected" "401" \
  "$(http_code "$APP_URL/api/settings" -H 'Authorization: Bearer definitely-wrong')"

section "an authenticated API call works over HTTPS"
assert_eq "GET /api/settings with the secret works" "200" "$(auth_code GET /api/settings)"

section "settings persist (write then read)"
marker="live_$(date +%s)"
assert_eq "a setting is written" "200" \
  "$(auth_code PUT /api/settings "$(jq -nc --arg v "$marker" '{railway_live_test:$v}')")"
assert_contains "the setting reads back" "$marker" "$(auth_get /api/settings)"

summary
