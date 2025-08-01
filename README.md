# Gatherly

A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.

## 🚀 Getting Started

### Prerequisites
- Docker (for containerized development)
- Git
- [mise](https://github.com/jdxcode/mise)
### Containerized Development (Recommended)

**One-command setup:**
```bash
git clone https://github.com/yourusername/gatherly.git
cd gatherly
mix dagger.dev  # Complete environment setup + start server
```

Visit [`localhost:4000`](http://localhost:4000) to see your app running.

### Development Workflows

```bash
# Daily development
mix dagger.dev.start        # Start services
mix dagger.dev.shell --iex  # Interactive development

# Database operations
mix dagger.db.reset         # Fresh database
mix dagger.db.shell         # Database debugging

# Code quality
mix dagger.quality --fix    # Format + lint + security
mix dagger.test             # Run tests

# CI verification (run exact same pipeline as CI)
mix dagger.ci               # Complete CI pipeline locally
mix dagger.deploy          # Build and push image to Fly.io (tagged with commit SHA)
```

**📖 For detailed development workflows, see [Dagger Integration Guide](lib/gatherly/dagger/README.md)**

### Tool Versions

- **Elixir**: 1.18.4-otp-28
- **Erlang/OTP**: 28.0.2
- **PostgreSQL**: 17.5
- **Phoenix**: 1.8.0-rc.4

All managed automatically in containers - no local installation needed.

## 🛠 Development

### Key Features
- **🐳 Containerized**: Consistent environments, no local dependencies
- **🔄 Hot Reloading**: Code changes automatically detected and reloaded
- **🗄️ Managed Database**: PostgreSQL runs as containerized service
- **⚡ Fast CI**: Run complete CI pipeline locally before pushing
- **🔧 Asset Pipeline**: TailwindCSS + esbuild handled by Phoenix (no Node.js required)

### Branching Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

### Code Standards
- Follow [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Use `mix dagger.quality --fix` for automated formatting and linting
- Verify changes with `mix dagger.ci` before pushing

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
