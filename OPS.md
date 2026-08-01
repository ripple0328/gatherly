# Gatherly Ops

`../mini-infra` is the canonical production operations implementation.
Gatherly's `Justfile` is a thin app adapter; do not copy deploy or launchd logic
into this repository.

Read-only and diagnostic commands:

```sh
just doctor
just status
just health
just logs
just tail
```

Change commands:

```sh
just install
just deploy
just migrate
just restart
just rollback
```

The normal deployment contract is deliberately strict: the worktree must be
completely clean, `HEAD` must exactly match its refreshed upstream, and the
mise-pinned `mix precommit` gate must pass without changing source. Releases
are immutable and record their source revision. Cutover uses a bounded graceful
SIGTERM restart, internal `/healthz` and `/readyz` checks, and the same checks
through `https://gatherly.qingbo.us`.

Production runtime configuration lives only on the Mini at:

```sh
~/.config/gatherly/env.runtime
```

It must define `PORT=4002`, `PHX_HOST=gatherly.qingbo.us`, `DATABASE_URL` for
Gatherly's own database, `SECRET_KEY_BASE`, and `PHX_SERVER=true`. Run
`just install` before the first golden-path deploy or whenever the launchd
label, environment file, app name, or release name changes.

Prometheus metrics remain available only on the Mini loopback interface at
`http://127.0.0.1:9568/metrics`. Aggregation uses
`TelemetryMetricsPrometheus.Core`; the HTTP projection uses the same maintained
Bandit stack as Phoenix rather than a second Cowboy server.
