# Gatherly — Ops & deployment (spec)

Goal: establish the dev→CI→deploy loop in **Iteration 0**.

## Target workflow

1) Develop locally
2) Push to GitHub
3) GitHub Actions runs CI on GitHub-hosted runners (Ubuntu)
4) If CI passes on `main`, GitHub Actions runs a **deploy job on a self-hosted runner** inside a private network
5) The self-hosted runner pulls/syncs code locally, builds a production release, runs migrations, and restarts the service

This avoids SSH-based deployments because the runner **is already on the target machine**.

## Reference implementation

Mirror the patterns from `../social_circle` (but for Gatherly we will rely on **GitHub Actions** for deployments; no direct local deploy command is required):

- `.github/workflows/ci.yml`
  - CI jobs on `ubuntu-latest`
  - Deploy job on `runs-on: [self-hosted]` (same workflow)

Self-hosted runner host (private network): **mini**
- Deploy path on runner: `~/Projects/Personal/gatherly`

You can still refer to these SocialCircle files as conceptual examples, but treat them as legacy/manual equivalents:
- `scripts/deploy-mini-local.sh`
- `scripts/mini-install.sh`
- `scripts/setup-github-runner.sh`
- `GITHUB_ACTIONS_SETUP.md`

## Self-hosted runner expectations

- Runner host is on the private network (e.g. macOS mini / local worker)
- Runner labels should include something like: `self-hosted, macOS, <worker-name>`
- Runner has:
  - Elixir/Erlang (prefer via `mise`)
  - build tooling (e.g. `mix`, `hex`, `rebar3`)
  - access to secrets (local `.envrc.<env>` file; do **not** commit)
  - database access (local container or service)

## Secrets strategy

- Keep secrets on the runner host (private machine) in a local env file, e.g. `.envrc.worker`.
- GitHub Secrets are optional; prefer local secrets for the private runner.

## Service management (macOS)

- Use LaunchAgent/launchctl to run the release.
- Store logs under the release log directory.

## Future: native clients

We want to extend Gatherly to native platforms (especially iOS and visionOS).

- Do **not** assume LiveView Native.
- Prefer an approach that keeps a stable backend and enables native clients (e.g., API-first surfaces, shared domain logic, and/or client SDKs) while preserving rapid iteration.

## Inbound access (for device testing)

We will use **Cloudflare Tunnel** (like SocialCircle) so iOS/visionOS devices can reach the dev/staging deployment without exposing ports.

- Create a dedicated tunnel for Gatherly
- Map a hostname (e.g. `gatherly.qingbo.us` or `gather.qingbo.us`)
- Prefer Cloudflare Access (auth gate) for non-public environments

Reference: `../social_circle/CLOUDFLARE_TUNNEL.md`
