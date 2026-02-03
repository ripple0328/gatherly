# Gatherly — AI plan (spec)

Gatherly intends to use AI extensively, preferably using the Elixir ecosystem.

## References
- Tidewave: https://tidewave.ai/
- Elixir AI agents ecosystem overview: https://elixirator.com/blog/elixir-for-ai-agents/

## Goals
- AI augments planning (logistics coverage, suggestions, summaries) without making the product fragile.
- Keep AI components modular (providers, prompts, tools) and observable.
- Clear safety boundaries: permissions, audit logging, and user-visible explanations.

## Where AI fits (initial)
- **Logistics assistant**: detect missing/duplicate items; suggest additions.
- **Potluck balancing**: variety + dietary coverage.
- **Discussion summarization**: concise summary + unresolved questions.
- **Location/time assistance**: commute-aware suggestions and ranking explanations.

## Architecture sketch (direction)
- Background orchestration via Elixir jobs (e.g., Oban) for non-blocking AI work.
- A small set of “tools” the AI can call (read event state, propose items, draft summary) with explicit authorization.
- Store AI outputs as first-class artifacts (e.g., suggestions, summaries) with provenance metadata.

## Open decisions
- Which AI framework/library choices to standardize on in Elixir.
- Data retention policy for prompts/outputs.
- Evaluation strategy (regression prompts, golden tests, human review loops).
