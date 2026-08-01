# Gatherly

Gatherly is a Phoenix LiveView reboot of a collaborative event planning workspace. The current foundation supports tokenized event access for owners and invited participants, invite-based participant submissions, participant self-edit links, owner review flows, and the existing workspace tools for logistics, proposals, and discussion.

## Ecosystem goal

Gatherly is the event-coordination app in a connected ecosystem with SayMyName
and Zonely. Each app remains independently useful and shares only
consent-based, versioned projections: SayMyName owns names and pronunciation,
Zonely owns team availability and reachability, and Gatherly owns event intent,
participation, proposals, and logistics. See
[the ecosystem charter](docs/ecosystem-charter.md).

## Local setup

Prerequisites are managed through `mise`; local services use Docker Compose.

```bash
mise install
mise x -- mix setup
mise x -- docker compose up -d db
```

Start the development server:

```bash
just dev
```

The golden-path dev server is exposed through Portless at `http://gatherly.localhost:1355`. Direct `mix phx.server` still defaults to `http://localhost:4000`.

## Development and validation

```bash
just test          # Start db and run the test suite
just format        # Run mix format
just precommit     # Start db and run mix precommit
mise x -- mix precommit
```

## Current surfaces

- `/` — product landing page
- `/events` and `/events/:slug` — event workspace entry and event detail
- `/events/:slug/invite/:token` — participant invite submission
- `/events/:slug/participants/:participant_id/edit/:token` — participant self-edit
- `/events/:slug/owner/:token` — owner review surface
- `/health`, `/healthz`, `/readyz`, `/version` — operational health and version endpoints

## Production operations

Production tasks are delegated through the root `Justfile` to the mini-infra workflow:

```bash
just deploy
just status
just health
just logs
just restart
just rollback
just migrate
```

Runtime secrets are provided by the configured environment file and must not be committed.
