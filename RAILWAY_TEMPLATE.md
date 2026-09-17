# Railway template configuration

The template's exact configuration. Reproduce it from this file if it ever has to be rebuilt.

| | |
|---|---|
| Name | GitHub Stars Manager |
| Code | `github-stars-manager` |
| Template id | `d7e31a05-dd0c-4f02-9dc8-709df1a1afcc` |
| Deploy URL | https://railway.com/deploy/github-stars-manager |
| Category | AI/ML |
| Card description | AI semantic search & auto-categorization for your GitHub stars. |
| Icon | `assets/icon.png` |
| Overview markdown | `marketplace/OVERVIEW.md` (Railway enforces its section headings) |

Generated values use Railway's `secret()` function: `hexN` is `${{secret(N, "abcdef0123456789")}}` and `alnumN` is
`${{secret(N, "a-zA-Z0-9")}}` spelled out. Alphanumeric passwords are used wherever a value is embedded in a
connection URL, so nothing needs percent-encoding. Images are referenced by tag, because the template generator
rejects digests; `UPSTREAM.md` records the digests.

## Services

### `app`

| Field | Value |
|---|---|
| Source | `ghcr.io/amintacccp/github-stars-manager-fullstack:v0.8.1` |
| Public domain | target port 3000 |
| Volume | `/app/data` |
| Healthcheck | `/health`, timeout from `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` |
| Restart policy | on failure, 10 retries |

| Variable | Value |
|---|---|
| `PORT` | `3000` |
| `API_SECRET` | generated, alnum48 |
| `ENCRYPTION_KEY` | generated, hex64 |
| `RAILWAY_RUN_UID` | `0` |
| `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` | `300` |

## Notes

- **Single service, official image unmodified.** One Node/Express process serves the SPA, the REST API and the MCP
  endpoints; SQLite on the `/app/data` volume. There is no wrapper image.
- **`API_SECRET` is the auth credential and must be set.** The app disables auth if it is unset (dev-mode), so the
  template generates it. Every `/api/*` route except `/api/health` (and `/health`) requires
  `Authorization: Bearer <API_SECRET>`. Single-user.
- **`ENCRYPTION_KEY`** is a generated 64-hex-char (32-byte AES-256) key that encrypts the GitHub/AI tokens you
  store. Keep it stable across redeploys so stored tokens stay decryptable.
- **`RAILWAY_RUN_UID=0`** — the image runs as the non-root `node` user; Railway mounts volumes as root, so this lets
  the process write `/app/data`.
- **`PORT` = 3000** = the domain target port; the app reads `PORT`. Health check `/health` (auth-exempt).
