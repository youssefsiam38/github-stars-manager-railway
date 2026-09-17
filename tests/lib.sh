#!/usr/bin/env bash
# shellcheck disable=SC2015
# Shared helpers for github-stars-manager-railway tests. Source this file; do not execute it.
# The API secret is never echoed. Auth is a Bearer token on /api/* (except /api/health).

: "${APP_URL:=http://localhost:${GSM_TEST_PORT:-13000}}"
: "${TEST_TIMEOUT:=300}"
: "${GSM_SECRET:=${GSM_TEST_API_SECRET:-local-test-only-api-secret-000000000000}}"

TEST_TMP="${TEST_TMP:-$(mktemp -d)}"
export TEST_TMP
_PASS=0; _FAIL=0

pass() { _PASS=$((_PASS+1)); printf '  PASS  %s\n' "$*"; }
fail() { _FAIL=$((_FAIL+1)); printf '  FAIL  %s\n' "$*" >&2; }
die()  { printf 'FATAL: %s\n' "$*" >&2; exit 1; }
section() { printf '\n== %s ==\n' "$*"; }
summary() { printf '\n%d passed, %d failed\n' "$_PASS" "$_FAIL"; [ "$_FAIL" -eq 0 ]; }

assert_eq() { if [ "$2" = "$3" ]; then pass "$1 ($3)"; else fail "$1: expected [$2] got [$3]"; fi; }
assert_contains() { if grep -q -- "$2" <<<"$3"; then pass "$1"; else fail "$1: missing [$2]"; fi; }

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 30 "$@" || true; }

wait_for_code() {
  local url=$1 want=$2 timeout=${3:-$TEST_TIMEOUT} start code
  start=$(date +%s)
  while :; do
    code=$(http_code "$url")
    [ "$code" = "$want" ] && return 0
    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then printf 'timed out waiting for %s -> %s (last %s)\n' "$url" "$want" "$code" >&2; return 1; fi
    sleep 3
  done
}

compose() { docker compose -f "$REPO_ROOT/compose.yaml" "$@"; }

# authed GET|PUT with the API secret
auth_code() {
  local method=$1 path=$2 body=${3:-}
  if [ -n "$body" ]; then
    http_code -X "$method" "$APP_URL$path" -H "Authorization: Bearer $GSM_SECRET" -H 'Content-Type: application/json' --data "$body"
  else
    http_code -X "$method" "$APP_URL$path" -H "Authorization: Bearer $GSM_SECRET"
  fi
}
auth_get() { curl -s --max-time 30 "$APP_URL$1" -H "Authorization: Bearer $GSM_SECRET"; }
