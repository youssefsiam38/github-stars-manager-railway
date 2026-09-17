# Maintenance

## Updating to a new upstream version

1. **Bump the pin.** Get the new digest (see `UPSTREAM.md`) and update `compose.yaml` and
   `_audit/spec_github_stars_manager.py`, and re-point the template's `app` image at the new tag.
2. **Run the tests locally.**
   ```bash
   tests/static.sh
   tests/smoke.sh
   tests/persistence.sh
   ```
3. **Re-verify on Railway.** Re-run the clean-room deploy + `tests/railway-smoke.sh` before updating the published
   template.

There is no wrapper image to build or publish — the template runs the official image unmodified, so CI only runs
the tests (there is no `publish-image` workflow).

## Rebuilding the Railway template from scratch

The exact configuration is in `RAILWAY_TEMPLATE.md`. The generator spec is `_audit/spec_github_stars_manager.py`;
the kit in `_audit/` (`tplkit.py`) builds a skeleton, patches the template, and runs a clean-room deploy. Volumes,
domains and health checks are only set by `skeleton()`, so a change to those requires rebuilding from a skeleton; if
`verify_template` reports an empty volume right after create, delete the template and re-create it.

## Gotchas worth remembering

- **`API_SECRET` must be set.** Without it the app disables auth. The template always generates it.
- **`RAILWAY_RUN_UID=0`.** The image runs as the non-root `node` user; Railway mounts volumes as root, so this lets
  the process write `/app/data`.
- **`PORT` = 3000** = the domain target port; the app reads `PORT` (default 3000). Health check `/health` (no auth).
- **`ENCRYPTION_KEY` is a 64-hex-char key.** Other formats are SHA-256-derived by the app; keep it stable across
  redeploys so stored tokens stay decryptable.
