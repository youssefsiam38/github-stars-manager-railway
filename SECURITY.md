# Security

## The API secret gates everything

GitHub Stars Manager is single-user and protects its API with a Bearer secret. If `API_SECRET` is not set, the app
runs with **auth disabled** (a dev-mode warning) — which on a public URL would let anyone read and change your data.
This template always generates and sets `API_SECRET`, so every `/api/*` route (except the credential-free `/health`
and `/api/health`) requires `Authorization: Bearer <API_SECRET>`. Verified in the smoke and live tests: a request
with no secret or a wrong secret is rejected (`401`); the correct secret works.

## What the template does

- **Generated API secret** (`API_SECRET`, 48 alphanumerics) — the single credential; copy it from the service
  variables to sign in to the backend.
- **Generated encryption key** (`ENCRYPTION_KEY`, 64 hex chars / 32 bytes) — the GitHub token and AI provider keys
  you store are encrypted at rest with AES-256. Setting it explicitly keeps the key deterministic (independent of
  the volume's auto-generated `.encryption-key`).
- **Pinned image.** The official image is pinned by digest (see `UPSTREAM.md`); the application is unmodified.
- **Secret hygiene.** No secret is committed; the static test greps the tree for credential shapes, and the tests
  read the secret from a mode-restricted file over HTTPS.

## What you should do

- **Copy and guard `API_SECRET`.** Anyone with it can read and manage your stars data. Rotate it by changing the
  variable (you will re-enter it in the app).
- **Keep `ENCRYPTION_KEY` stable.** Changing it makes previously stored encrypted tokens undecryptable; you would
  re-enter your GitHub/AI keys. Back it up if you back up the volume.
- **Your GitHub token is yours.** Give the app a token with only the scopes it needs; it is stored encrypted on the
  volume, not shared with this template.
- **Back up the volume** (`/app/data`) with Railway's volume backups.

## Reporting

For issues in GitHub Stars Manager itself, report upstream. For issues specific to this template's packaging, open
an issue on the template repository.
