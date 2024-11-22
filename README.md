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

0. Once off setup

Setup database with db and user
```bash
cd gatherly
direnv allow
initdb
devbox run db
createdb $USER
```

create role `postgres`

```
$ psql
# CREATE USER postgres SUPERUSER;
# \q
```

install npm packages
```
cd assets
npm i
```
create DB for this app

run db setup
```
devbox run setup
```

app using google oauth, so need app id and secret, you can create it from [google cloud console](https://console.cloud.google.com/apis/credentials)

```bash
set secrets to mac keyvaults, direnv will populate that to local session
```bash
envchain -s gatherly GOOGLE_CLIENT_ID
envchain -s gatherly GOOGLE_CLIENT_SECRET
```

install npm packages
```bash
devbox run npm_install
```
1. start db and server

```bash
devbox run postgres
devbox run start
```

Accessing it via http://localhost:4000
Access telemetry dashboard at http://localhost:4000/metrics
Access with NativeApp via LVN go App on http://localost:4000/

2. Run tests

```bash
devbox run test
```

3. format code

```bash
devbox run format
```
## Apple Apps

open project in xcode
```bash
open native/apple/ios/Gatherly.xcodeproj
```
give it time for initial dependency download and indexing

run the app in simulator with |> button

## Trouble shooting

### delete migration records
```bash
devbox run remote
```

```elixir
alias Gatherly.Repo
table_name = "schema_migrations"

# Construct the query to delete all records
import Ecto.Query, only: [from: 1]
query = from(u in table_name)

# Execute the deletion with error handling
try do
  Repo.delete_all(query)
rescue
  e in Ecto.QueryError -> IO.puts("Query Error: #{e.message}")
  e in Postgrex.Error -> IO.puts("Postgrex Error: #{e.message}")
  e in DBConnection.ConnectionError -> IO.puts("Connection Error: #{e.message}")
end
```
