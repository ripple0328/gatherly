


# Gatherly

A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.

## 🚀 Getting Started

### Prerequisites

- Elixir 1.14+ (with Mix)
- Erlang/OTP 25+
- PostgreSQL 14+
- Node.js 16+ (for asset compilation)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gatherly.git
   cd gatherly
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   cd assets && npm install && cd ..
   ```

3. **Set up the database**
   ```bash
   # Create and migrate your database
   mix ecto.setup
   ```

4. **Start the Phoenix server**
   ```bash
   mix phx.server
   ```

   Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## 🛠 Development Workflow

### Branching Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches (e.g., `feature/user-authentication`)
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

### Code Style

- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Run the formatter before committing:
  ```bash
  mix format
  ```
- Use `mix credo` for static code analysis

### Running Tests

```bash
# Run all tests
mix test

# Run tests for a specific file
mix test test/path/to/test_file_test.exs

# Run a specific test
mix test test/path/to/test_file_test.exs:123
```

### Database Migrations

```bash
# Create a new migration
mix ecto.gen.migration migration_name

# Run migrations
mix ecto.migrate

# Rollback the last migration
mix ecto.rollback
```

### Asset Management

- JavaScript and CSS are managed through `esbuild`
- TailwindCSS is included by default
- To watch for changes in assets:
  ```bash
  cd assets && npm run watch
  ```

## 🧪 Testing

### Test Coverage

```bash
# Generate test coverage report
MIX_ENV=test mix coveralls.html
```

### Linting

```bash
# Run Credo for code analysis
mix credo

# Run Credo with strict checks
mix credo --strict
```

## 🚀 Deployment

### Production Build

```bash
# Get dependencies with production config
MIX_ENV=prod mix deps.get --only prod

# Compile and build assets
MIX_ENV=prod mix assets.deploy

# Run database migrations
MIX_ENV=prod mix ecto.migrate

# Start the Phoenix server
MIX_ENV=prod mix phx.server
```

### Docker

```bash
# Build the Docker image
docker build -t gatherly .

# Run the container
docker run -p 4000:4000 gatherly
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📌 Project Roadmap

### Phase 0: Foundations
- [ ] Phoenix + LiveView scaffolding
- [ ] TailwindCSS setup
- [ ] Dev/test deployment (Fly.io or Render)
- [ ] OAuth login (Google, Apple, Facebook, X)
- [ ] Anonymous join via magic link

### Phase 1: MVP – Potluck Planning
- [ ] Create & join events (potluck only)
- [ ] Event page with:
  - [ ] Basic info
  - [ ] RSVP
  - [ ] Participant list
  - [ ] Discussion forum
- [ ] Time/location proposal & voting
- [ ] Logistics board (food/items)
  - [ ] Add item
  - [ ] Assign owner
  - [ ] Track status
  - [ ] AI assistant feedback
- [ ] Commute time visualization
- [ ] PWA baseline

### Phase 2: Multi-Event Support
- [ ] Add Camping, Hiking, Game Night templates
- [ ] Template-specific logistics and checklists
- [ ] Carpool, fitness filters, gear sharing, etc.

### Phase 3: AI-Powered Assistance
- [ ] AI checklist/template suggestions
- [ ] Food/item coverage analysis
- [ ] Smart commute-aware location suggestions
- [ ] AI prompt-based planning assistant

### Phase 4: Mobile & Real-Time UX
- [ ] Real-time updates (PubSub)
- [ ] Live notifications
- [ ] Full PWA experience
- [ ] Begin LiveView Native prep

---

## 🧠 Technical Documentation

### Core Entities (DB Schema)

#### Users
- `id`, `name`, `email`, `avatar_url`, `login_provider`, `last_seen_at`

#### Events
- `id`, `title`, `description`, `event_type`, `creator_id`, `visibility`, `created_at`

#### Event Participants
- `id`, `event_id`, `user_id`, `invite_token`, `rsvp_status`

#### Proposals (Location/Time)
- `id`, `event_id`, `type`, `value`, `proposed_by`, `created_at`

#### Votes
- `id`, `proposal_id`, `user_id`, `weight`

#### Logistics Items
- `id`, `event_id`, `name`, `quantity`, `category`, `flavor_profile`, `status`, `owner_id`, `ai_flagged`, `comments`

#### Comments
- `id`, `event_id`, `author_id`, `body`, `created_at`

### LiveView Component Map

- `/events/:id` → `EventShowLive`
  - `EventHeader`
  - `RSVPBox`
  - `ProposalVotePanel` (Location/Time)
  - `LogisticsBoard`
  - `CommuteMap`
  - `DiscussionForum`

Components:
- `Event.RSVPForm`, `Event.ProposalForm`, `Logistics.ItemForm`, `AI.FoodSuggestionCard`, `Map.CommuteVisualizer`, `Forum.ThreadComponent`