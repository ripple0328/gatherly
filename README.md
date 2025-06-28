# Gatherly

A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.

## 🚀 Getting Started

### Prerequisites

- [Claude Code](https://claude.ai/code) or compatible container runtime
- Git

### Development with Containers (Recommended)

The recommended way to develop Gatherly is using containers, which eliminates the need to install Elixir, Erlang, PostgreSQL, and Node.js locally.

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gatherly.git
   cd gatherly
   ```

2. **Start the development environment**

   Using Claude Code or compatible container tooling:
   ```bash
   # Open the project in a containerized environment
   # The environment will automatically:
   # - Install Elixir 1.18.4 with Erlang/OTP 27
   # - Install Node.js 24.2.0
   # - Set up PostgreSQL 16
   # - Install all dependencies
   # - Run database migrations
   # - Start the Phoenix server
   ```

3. **Access the application**

   The development server will be available at the provided external URL (typically `http://127.0.0.1:<port>`).

4. **View your changes**

   To view your work from the host system:
   ```bash
   git checkout <container-branch-name>
   ```

### Tool Versions

The project uses the following versions as specified in `.tool-versions`:

- **Elixir**: 1.18.4-otp-28
- **Erlang/OTP**: 28.0.1

### Native Installation (Alternative)

If you prefer to run natively, ensure you have:

- Elixir 1.18+ (with Mix)
- Erlang/OTP 27+
- PostgreSQL 14+
- Node.js 24+ (for asset compilation)
- Git

Then follow these steps:

1. **Install dependencies**
   ```bash
   mix deps.get
   cd assets && npm install && cd ..
   ```

2. **Set up the database**
   ```bash
   # Create and migrate your database
   mix ecto.setup
   ```

3. **Start the Phoenix server**
   ```bash
   mix phx.server
   ```

   Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## 🛠 Development Workflow

### Container-Based Development

When using containers, the development workflow is streamlined:

- **Hot reloading**: Code changes are automatically detected and reloaded
- **Database**: PostgreSQL runs as a service within the container environment
- **Assets**: Tailwind CSS and ESBuild are automatically configured and watch for changes
- **Dependencies**: All dependencies are managed within the container

### Development Commands (Container)

Common tasks in the containerized environment:

```bash
# Install/update dependencies
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix deps.get'

# Run tests
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix test'

# Format code
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix format'

# Run static analysis
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix credo'

# Database operations
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.migrate'
bash -c '. /opt/asdf.sh && ELIXIR_ERL_OPTIONS="+fnu" mix ecto.reset'
```

### Branching Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches (e.g., `feature/user-authentication`)
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes
- `container-use/*` - Container environment branches (auto-managed)

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
- Assets are automatically built and watched in the container environment
- For manual asset operations:
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
3. Work in the containerized development environment
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📌 Project Roadmap

### Phase 0: Foundations
- [x] Phoenix + LiveView scaffolding
- [x] TailwindCSS setup
- [x] Container-based development environment
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
