# Gatherly — Ops & deployment

**Single source of truth:** see the Platform docs and scripts.

- Platform ops spec: `/Users/qingbo/Projects/Personal/platform/docs/OPS.md`
- Secrets: `/Users/qingbo/Projects/Personal/platform/docs/SECRETS.md`
- Deploy scripts: `/Users/qingbo/Projects/Personal/platform/scripts/`
- Ops entrypoints: `/Users/qingbo/Projects/Personal/platform/Justfile`

## Deploy flows

### GitHub Actions (runner on mini)
- Runner pulls from GitHub on the mini, builds, migrates, restarts.
- Uses `platform/scripts/deploy-mini.sh` (git fetch + reset).

### Local (Mac Studio → mini)
- Sync committed code from Studio to mini, then build + restart.
- Use:
  ```bash
  just deploy-mini-local
  ```

## Gatherly wrappers

Gatherly’s `Justfile` is a thin wrapper over the platform Justfile. Use:
- `just deploy-mini` (runner / git-pull flow)
- `just deploy-mini-local` (local rsync flow)

## Inbound access

Use Cloudflare Tunnel + Access. See platform docs for the canonical setup.
