# Gatherly — Stack policy

This project should target **latest stable** versions unless a specific dependency forces a pin.

## Defaults
- Elixir: latest stable
- Erlang/OTP: latest stable compatible with Elixir
- Phoenix: latest stable
- Phoenix LiveView: latest stable compatible with Phoenix
- Ash Framework: latest stable (and related Ash packages)
- AI/Agents/Observability: prefer Elixir-native ecosystem; evaluate and integrate Tidewave where it helps (see https://tidewave.ai/)

## Notes
- Prefer upgrading early to avoid long-tail migration costs.
- Keep a short CHANGELOG section here when versions are chosen/pinned.
