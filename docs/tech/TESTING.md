# Gatherly — Testing strategy (task-driven)

Goal: implement Linear tasks with high confidence by having clear, automatable success criteria and tests.

## Principles
- Every Linear task should declare **success criteria** and **required tests**.
- Prefer deterministic tests (stable fixtures, no flaky timing).
- CI should make it hard to merge broken builds.

## Test layers

### 1) Unit / domain tests (fast)
- Pure domain logic and invariants.
- Ash resources/policies validations (once implemented).

### 2) Integration tests
- DB-backed behavior (Postgres), migrations, resource actions.
- API handlers / channels / pubsub boundaries.

### 3) End-to-end (smoke)
- Minimal “happy path” checks for key flows.
- Keep small and stable (few scenarios), run in CI on main.

## API contract tests (for native clients)
If native clients consume an API:
- Define explicit contracts (request/response schemas).
- Add contract tests to ensure backward compatibility.
- Version the API if needed.

## CI gates
Recommended gates for PRs:
- format check
- compile with warnings-as-errors
- unit + integration tests
- assets build (if applicable)

For `main` deploy:
- all of the above, plus a lightweight runtime smoke check on the self-hosted runner after restart.

## Definition of Done (per task)
For each Linear task, use the template in `tech/TASK_TEMPLATE.md`.

Minimum expectations:
- Success criteria: explicit, testable bullets
- Tests: explicit list (unit/integration/e2e/contract)
- Observability: logs/telemetry if it’s user-facing or async
- Rollout/backout: at least a short note

## Tagging tasks
Use labels/checklists to denote required test types:
- `tests:unit`
- `tests:integration`
- `tests:e2e`
- `tests:contract`

This makes it easier for the agent to implement tasks autonomously.
