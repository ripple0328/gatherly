# Gatherly
[![codecov](https://codecov.io/github/ripple0328/gatherly/graph/badge.svg?token=NZJ5IIWRIK)](https://codecov.io/github/ripple0328/gatherly)
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

1. Install dependencies
```bash
devbox shell
mix deps.get
```
2. Sart DB, Create and migrate your database

```bash
mix ecto.create
mix ecto.migrate
```

3. Start the app
To start the app locally for development, run the following command:

```bash
mix phx.server
```
try accessing it via http://localhost:4000

4. Run tests

```bash
mix test
```

5. format code

```bash
mix format
```
