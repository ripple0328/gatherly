


# Gatherly

A collaborative event planning platform designed for group-based activities such as potlucks, camping, hiking, and game nights. Built with Phoenix LiveView and PWA-first principles.

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