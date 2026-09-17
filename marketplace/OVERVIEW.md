# Deploy and Host GitHub Stars Manager on Railway

GitHub Stars Manager is an open-source, AI-powered manager for your GitHub stars: semantic search across everything
you've starred, automatic categorization, and release tracking — with a web UI and MCP endpoints. This template
deploys it as a single self-hosted service protected by a generated API secret. It is a community-maintained
template and is not affiliated with the GitHub Stars Manager project.

## About Hosting GitHub Stars Manager

GitHub Stars Manager is a single Node/Express process that serves its web UI, its REST API and its MCP endpoints,
storing everything in SQLite on disk. It is single-user and protects its API with a Bearer secret — but if that
secret is not configured, it runs with authentication disabled, which on a public URL would let anyone read and
change your data. It also encrypts the tokens you store (your GitHub token and AI provider keys) with a key you
provide.

This template runs GitHub Stars Manager on Railway with a generated API secret (so the API is always protected), a
generated encryption key (so stored tokens are encrypted at rest), the SQLite database persisted on a volume, and
the port and health check wired. It runs the official image unmodified, pinned by digest.

## Common Use Cases

- Making sense of hundreds or thousands of GitHub stars with AI semantic search and auto-categorization.
- Tracking new releases of the repositories you've starred.
- Exposing your starred-repo knowledge to an AI assistant over MCP, behind your own secret.

## Dependencies for GitHub Stars Manager Hosting

- Nothing external — the database is embedded (SQLite on the volume).
- To use the AI features and import your stars you provide your own GitHub token and an AI provider key, entered in
  the app.

### Deployment Dependencies

- GitHub Stars Manager: https://github.com/AmintaCCCP/GithubStarsManager (MIT)
- Template repository and tests: https://github.com/youssefsiam38/github-stars-manager-railway

### Implementation Details

The app runs upstream's official full-stack image (one process serves the SPA, API and MCP endpoints), pinned by
digest and unmodified. The template generates `API_SECRET` and sets it so the API is always behind Bearer auth
(every `/api/*` route except `/api/health`, plus `/health`, is the only open path), generates `ENCRYPTION_KEY`
(a 64-hex-character AES-256 key) to encrypt stored tokens, sets `RAILWAY_RUN_UID=0` so the non-root image can write
its `/app/data` volume, and wires `PORT`, the public domain and the `/health` check.

Tested in CI and on a live deployment of this template: the app is healthy, the SPA is served, the API rejects a
request with no secret or a wrong secret and accepts the correct one, and a setting written through the API survives
a redeploy.

After deploying, copy `API_SECRET` from the service's variables, open the app, and paste it when asked for the
backend secret. Then add your GitHub token and an AI provider in the app to import and search your stars.

## Why Deploy GitHub Stars Manager on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you
don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying GitHub Stars Manager on Railway, you are one step closer to supporting a complete full-stack
application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
