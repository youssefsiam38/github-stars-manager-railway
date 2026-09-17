# Upstream and pinned versions

This template runs **GitHub Stars Manager** from its official full-stack image, pinned by digest. There is no
wrapper image — the application is used unmodified and configured entirely through environment variables.

## GitHub Stars Manager

- Project: https://github.com/AmintaCCCP/GithubStarsManager
- Licence: MIT (`licenses/GITHUBSTARSMANAGER-LICENSE`)
- Official image: `ghcr.io/amintacccp/github-stars-manager-fullstack` (one Node/Express process serves the SPA,
  the API and the MCP endpoints)
- Pinned: `ghcr.io/amintacccp/github-stars-manager-fullstack:v0.8.1`
  - digest `sha256:c718c2d264d3ebb181661b52725fb29712016a73cd13cac88084cb9aeff30d1f` (multi-arch index; linux/amd64: `sha256:9d581fae2d13d388a0c93749a0704086dc878d2f8db6efd6e1d1f49f3cc04359`)

## Refreshing a digest

```bash
docker buildx imagetools inspect ghcr.io/amintacccp/github-stars-manager-fullstack:<tag> --format '{{json .Manifest}}' | jq -r .digest
```

Update the pins here, in `compose.yaml`, and in `_audit/spec_github_stars_manager.py`, then re-run the tests and
re-point the template at the new tag. See `MAINTENANCE.md`.
