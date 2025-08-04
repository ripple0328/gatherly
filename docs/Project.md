


# 📘 Gatherly: Project Overview and Roadmap

Gatherly is a collaborative, AI-powered event planning platform designed for casual group gatherings. Unlike traditional event tools that silo scheduling, invitations, and task coordination into separate apps, Gatherly brings everything together—so people can crowdsource their plans, distribute logistics, and make smarter decisions as a group.

---

## 🎯 Product Vision

Gatherly empowers every participant—not just the host—to contribute meaningfully to event planning. From scheduling and location selection to food assignments and carpool planning, the app facilitates a shared planning experience. AI assists throughout the process, suggesting options, resolving bottlenecks, and ensuring coverage of key logistics.

---

## 🧩 Key Features

### 1. Event Creation and Participation
- Create events with title, description, event type.
- Supports event types: Potluck, Camping, Hiking, Game Night (more in future).
- Share invite links via social login (Google, Apple, Facebook, X) or anonymous magic links.
- Anonymous link access allows full participation (RSVP, voting, logistics, etc.) without login.
- RSVP system with guest status tracking.

### 2. Proposals and Voting
- Anyone can propose date/time and location.
- Voting outcome is majority-based by default, but the event creator can optionally lock the decision.
- Commute visualization assists participants during the proposal phase, not just final voting (e.g. heatmaps based on travel time).

### 3. Collaborative Forum
- Threaded discussion integrated per event.
- Use forum to propose, coordinate, or clarify decisions.
- AI summarization can help highlight unresolved topics or common themes.

### 4. Logistics Toolkit (Core Differentiator)
- Logistics is the core value proposition of Gatherly.
- Dynamic templates per event type:
  - **Potluck**: Dish sign-up, quantity input, dietary tags, flavor categories.
  - **Camping**: Gear checklist, shared items, ride assignments, weather-based suggestions.
  - **Hiking**: Trail planning, gear list, fitness level flags, emergency contact setup.
  - **Game Night**: Game library suggestions, snack list, seating and setup planning.
- Each logistics item supports:
  - Owner assignment
  - Editable status (unassigned, planned, in progress, done)
  - Quantity
  - Tags or notes
  - Optional reminders or due dates
  - AI-generated feedback (e.g. “too many desserts”, “no flashlight assigned”)
- Progress reporting visualizes item completion for all participants.
- Templates serve as starting points and can be customized by event creator.

### 5. AI Assistance
- AI is integrated across the app: item suggestions, location/time optimization, and real-time assistance.
- Suggest items based on event type and participant data.
- Detect missing or duplicated items in logistics.
- Balance food menus for potlucks (flavor, nutrition, variety).
- For food-related events, flavor preferences and quantity recommendations are included.
- Optimize location/time based on commute data and participant availability.

### 6. Commute Visualizer
- Map view shows location impact for all participants.
- Commute times aggregated and visualized.
- Displayed during location proposal and voting, not just after selection.
- Data supports optimized location scoring to help the group choose the best option.

### 7. Event Summary & Real-Time Updates
- Real-time logistics dashboard for all participants.
- Progress tracking on task/item completion.
- AI-generated event summary view (what, where, when, who's doing what).
- Event summary can be exported or shared.
- Optional participant summaries (e.g. assigned items, travel time) can be emailed.

---

## 🗓️ Development Roadmap

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

## Technical Documentation

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

---

## 👥 Who Is This For?

- Families and friend groups organizing casual events.
- Clubs and community groups managing shared outings.
- People frustrated with fragmented planning tools or chat chaos.

Gatherly is not just an event invite platform—it's a planning engine, coordination hub, and AI assistant, designed to make group planning fun, fair, and frictionless.
