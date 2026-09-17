# Marketplace audit

A record of the diligence behind publishing this template.

## Identity

- Template: **GitHub Stars Manager** — an AI-powered manager for your GitHub stars (semantic search,
  auto-categorization, release tracking).
- Upstream: [AmintaCCCP/GithubStarsManager](https://github.com/AmintaCCCP/GithubStarsManager), MIT, active (~3.6k stars).

## Licence

- MIT (`licenses/GITHUBSTARSMANAGER-LICENSE`); redistribution as a template is permitted. The official image is used
  unmodified; there is no wrapper. See `THIRD_PARTY_NOTICES.md`.

## Security review

- **Bearer auth enforced.** `API_SECRET` gates every `/api/*` route except `/api/health`; the app disables auth if
  it is unset, so the template always generates and sets it. A request with no/wrong secret is rejected (401),
  verified live.
- **Encryption at rest.** `ENCRYPTION_KEY` (generated, 64-hex) encrypts the stored GitHub/AI tokens.
- **Secret hygiene.** No secret is committed; the tests read the secret from a mode-restricted file and never print
  it; the static test greps the tree for credential shapes.
- **Reproducible.** The image is pinned by digest.

## Reproducibility & tests

- `tests/static.sh` (15 checks): syntax, shellcheck, compose shape, digest pin, auth wiring, secret scan.
- `tests/smoke.sh` (7 checks): health, SPA served, `/api/health` open, bearer required (no/wrong secret → 401), an
  authenticated API call works.
- `tests/persistence.sh` (4 checks): a setting written via the API survives a restart (SQLite on the volume).
- `tests/railway-smoke.sh`: the same flows over HTTPS against the deployed template.
- CI runs static + smoke + persistence on every push (no image build — the official image is used unmodified).

## Deploy-time inputs

- `API_SECRET` — generated (the Bearer secret; copy it to sign in).
- `ENCRYPTION_KEY` — generated (encrypts stored tokens).
- Everything else is fixed by the template (port, health check, volume, run-as-root). No required human input beyond
  clicking deploy; using the app needs your own GitHub token and AI provider key, entered in the UI.

## Verdict

Shippable. A self-contained, reproducible, secret-authenticated single-service deployment whose auth and persistence
are verified on a live Railway deployment.
