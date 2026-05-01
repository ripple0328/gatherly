# Gatherly reboot brief

## Mission

Gatherly is a crowd-powered event organization workspace for casual groups. One person starts an event, shares a link, participants onboard themselves, and the group collectively resolves attendance, decisions, logistics, and discussion without relying on a permanent central admin.

## First wedge

Start with potlucks because they make the core loop obvious: RSVP, discuss, and claim who brings what. Later event templates can reuse the same primitives for camping, hiking, game nights, and recurring groups.

## Durable concepts

- `Event`: primary planning unit.
- `Participant`: self-authored event contribution; claimable by an account later.
- `Invite`: low-friction share surface; append-self, not admin authority.
- `LogisticsItem`: item/task with quantity, owner, status, category, tags, and notes.
- `Proposal` + `Vote`: future time/location decision mechanism.
- `Comment`: event-local discussion.
- `Team`: later reusable group derived from event participants when needed.

## Product principles

- Show value before account creation.
- Keep ownership distributed: participants edit their own contributions and can claim logistics.
- Preserve source/provenance so no-account contributions can be claimed later.
- Keep event templates additive; potluck should not hard-code a product dead end.
- Treat AI as an assistant layer after the core human workflow is stable.

## Bootstrap pattern borrowed from Zonely

- Creator starts a draft/event and receives owner authority.
- Invitees use an opaque link to add only themselves.
- Owner/review flows can accept, reject, exclude, and publish idempotently.
- Accounts, co-maintainers, revocable invites, and durable teams arrive after the low-friction event loop proves value.

## Stack baseline

Phoenix 1.8, LiveView, Ecto, PostgreSQL, Tailwind, Bandit, `mise`, Portless/Tidewave locally, and mini-infra launchd deployment with `/healthz`, `/readyz`, and `/version` platform endpoints.
