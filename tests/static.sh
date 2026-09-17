#!/usr/bin/env bash
# shellcheck disable=SC2015,SC2016
# Static validation: syntax, shellcheck, compose, image pin and security defaults. No Docker build.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
cd "$REPO_ROOT"
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"

section "syntax"
for f in tests/*.sh; do
  if bash -n "$f" 2>/dev/null; then pass "parses: $f"; else fail "syntax error: $f"; fi
done

section "shellcheck"
if command -v shellcheck >/dev/null; then
  if shellcheck -x -s bash tests/*.sh; then pass "shellcheck tests"; else fail "shellcheck tests"; fi
else
  echo "  SKIP  shellcheck not installed"
fi

section "compose"
if docker compose -f compose.yaml config -q; then pass "compose config"; else fail "compose config"; fi
cfg=$(docker compose -f compose.yaml config --format json)
assert_eq "one service" "app" "$(jq -r '[.services | keys[]] | sort | join(" ")' <<<"$cfg")"
assert_eq "the port binds to loopback" "127.0.0.1" "$(jq -r '[.services.app.ports[]? | .host_ip] | join(" ")' <<<"$cfg")"
assert_eq "the data volume is mounted" "/app/data" "$(jq -r '[.services.app.volumes[]? | .target] | join(" ")' <<<"$cfg")"
assert_contains "the app image is the official full-stack image, pinned by digest" \
  '^ghcr.io/amintacccp/github-stars-manager-fullstack:.*@sha256:[0-9a-f]\{64\}$' "$(jq -r '.services.app.image' <<<"$cfg")"
assert_contains "API_SECRET is wired (bearer auth)" 'API_SECRET' "$cfg"
assert_contains "ENCRYPTION_KEY is wired" 'ENCRYPTION_KEY' "$cfg"

section "auth posture"
# The compose secret must be an obvious placeholder, not a real secret.
assert_contains "the compose API secret is a placeholder" 'local-test-only' "$(jq -r '.services.app.environment.API_SECRET' <<<"$cfg")"

section "secrets hygiene"
mapfile -t tracked < <(git ls-files 2>/dev/null | grep . || find . -type f -not -path './.git/*' -not -path './test-output/*')
if [ "${#tracked[@]}" -gt 0 ] && grep -lE '(sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)' "${tracked[@]}" 2>/dev/null; then
  fail "a credential-shaped string is in the repository"
else
  pass "no credential-shaped strings in ${#tracked[@]} files"
fi

summary
