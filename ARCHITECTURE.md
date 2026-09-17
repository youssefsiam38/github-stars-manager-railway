# Architecture

## Service graph

```
        Railway HTTPS edge
              │
              ▼
   ┌─────────────────────────────────────────────┐
   │  app  (public domain :3000)                  │  volume: /app/data
   │  one Node/Express process:                   │   - SQLite (settings, categories,
   │   - SPA (static)         GET /                │     configs, encrypted tokens)
   │   - REST API             /api/*  (Bearer)     │   - .encryption-key (only if
   │   - MCP endpoints        /api/mcp/* + /mcp    │     ENCRYPTION_KEY is not set)
   │   - health               /health, /api/health│
   └─────────────────────────────────────────────┘
```

One service, one process. There is no separate frontend, database or cache — the SPA is served statically and the
data lives in SQLite on the `/app/data` volume.

## The app service

- Image: the official `ghcr.io/amintacccp/github-stars-manager-fullstack`, pinned by digest, used unmodified.
- **Port:** reads `PORT` (default 3000). The template sets `PORT=3000`, the public domain's target port to `3000`,
  and the health check to `/health` (auth-exempt) — all aligned.
- **Auth:** `API_SECRET` is a generated Bearer token. The auth middleware requires it on every `/api/*` route
  except `/api/health`; `/health` is also exempt. If `API_SECRET` were unset the app would run with auth disabled
  (a dev-mode warning), so the template always sets it. Single-user by design.
- **Encryption:** `ENCRYPTION_KEY` (generated, 64-hex-char = 32-byte AES-256 key) encrypts the secrets you store
  (GitHub token, AI provider keys). If it is unset the app generates one and writes it to `/app/data/.encryption-key`;
  the template sets it explicitly so the key is deterministic and independent of the volume.
- **Volume:** `/app/data` holds the SQLite database. The image runs as the non-root `node` user, so the template
  sets `RAILWAY_RUN_UID=0` (Railway mounts volumes as root; this lets the process own its data directory).

## Data & integrations

Your GitHub token and AI provider keys are entered in the app and stored encrypted in SQLite. Semantic search and
auto-categorization call the AI provider you configure; nothing runs until you add those credentials, which are
yours and stay on the volume.
