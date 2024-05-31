# Gatherly
[![CI](https://github.com/ripple0328/gatherly/actions/workflows/ci.yml/badge.svg)](https://github.com/ripple0328/gatherly/actions/workflows/ci.yml)
[![codecov](https://codecov.io/github/ripple0328/gatherly/graph/badge.svg?token=NZJ5IIWRIK)](https://codecov.io/github/ripple0328/gatherly)
[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)


Gatherly is an application that allow coordinate party like activities.


# Planned Features

- [ ] Coordinate People's Calendars and Availability
- [ ] Online Status Tracking and Chatting
- [ ] Route Planning based on location and arrive time
- [ ] Coordinate Items Might Bring and Track Amount By Category
- [ ] Member Requests for Items
- [ ] Forming Reusable Templates

## Getting Started

These instructions will guide you on how start the app locally for development

0. Once off
```bash
cd gatherly
initdb
mix ecto.setup
```

1. Install dependencies
```bash
mix phx.server
```
Accessing it via http://localhost:4000

2. Run tests

```bash
mix test
```

3. format code

```bash
mix format
```
