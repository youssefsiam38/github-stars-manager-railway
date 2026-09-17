# GitHub Stars Manager on Railway

A one-click [Railway](https://railway.com) template that runs
[GitHub Stars Manager](https://github.com/AmintaCCCP/GithubStarsManager) — an AI-powered manager for your GitHub
stars with semantic search, auto-categorization and release tracking. It is a single self-hosted service with a web
UI, protected by a **generated API secret**.

This is a community-maintained template and is not affiliated with the GitHub Stars Manager project.

- **Image:** the official `ghcr.io/amintacccp/github-stars-manager-fullstack`, pinned by digest, used unmodified —
  see [UPSTREAM.md](UPSTREAM.md)

## What you get

- One service: a single Node/Express process serving the SPA, the API and the MCP endpoints, with SQLite on a
  `/app/data` volume.
- A **generated `API_SECRET`** — the API requires it as a Bearer token (single-user), so a stranger who finds your
  URL cannot read or change your data.
- A **generated `ENCRYPTION_KEY`** — secrets you store (your GitHub token, AI provider keys) are encrypted at rest.

## Deploy

1. Click **Deploy on Railway** and wait for the service to go healthy.
2. Open the service → **Variables** and copy `API_SECRET`.
3. Open the public domain, and when the app asks for the backend secret, paste `API_SECRET`.

## Use it

In the app, add your **GitHub token** (to import your stars) and an **AI provider** (for semantic search and
auto-categorization) — these are your own credentials, stored encrypted on the volume. The MCP endpoints let an MCP
client query your stars; they use the same `API_SECRET`.

## Security

- The API secret gates every `/api/*` route (except `/health` and `/api/health`); treat it like a password and
  rotate it by changing `API_SECRET`.
- Your stored tokens are encrypted with `ENCRYPTION_KEY`. See [SECURITY.md](SECURITY.md).

## Repository layout

| Path | What |
|---|---|
| `compose.yaml` | Local test topology (the official image + a volume) |
| `tests/` | Static, smoke, persistence, and live (HTTPS) tests |
| `marketplace/OVERVIEW.md` | The marketplace overview shown on the template page |
| `RAILWAY_TEMPLATE.md` | The exact published template configuration |
| `UPSTREAM.md` · `SECURITY.md` · `ARCHITECTURE.md` · `MAINTENANCE.md` | Reference docs |

## Local development

```bash
docker compose up          # run the official image with a volume
tests/smoke.sh             # health, SPA, bearer auth, authed API
tests/persistence.sh       # settings survive a restart
```

## Licence

The template's own files are MIT (`LICENSE`). GitHub Stars Manager keeps its own licence; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
