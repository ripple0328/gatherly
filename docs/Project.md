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

### Phase 0 – Foundation (Weeks 1–2)
- [ ] Phoenix + LiveView scaffolding
- [ ] TailwindCSS setup
- [ ] modern design and stunning ui home page to show case the app's features and use cases
- [ ] OAuth login + anonymous link join
- [ ] deployment to fly.io

### Phase 1 – MVP: Potluck Planning (Weeks 3–6)
- [ ] Event creation with RSVP
- [ ] Shared task/item board for food
- [ ] Proposal + voting for location/time
- [ ] Basic discussion forum
- [ ] Commute visualizer (Google Maps)
- [ ] Smart vote/commute recommendation

### Phase 2 – Multi-Event Logistics Templates (Weeks 7–10)
- [ ] Templates for Camping, Hiking, Game Night
- [ ] Assignable logistics items per template
- [ ] AI contextual suggestions (e.g. weather-aware packing list)

### Phase 3 – Deep AI Integration (Weeks 11–14)
- [ ] AI menu assistant (OpenAI API or similar)
- [ ] AI-based item deduplication and logistics validation
- [ ] AI assistant prompt bar (“Help us plan a safe camping trip”)

### Phase 4 – Mobile Polish & Real-Time UX (Weeks 15–18)
- [ ] PubSub-based live updates
- [ ] PWA install banners, background sync
- [ ] Notification system (email + push)
- [ ] LiveView Native foundations for mobile deployment

---

## 👥 Who Is This For?

- Families and friend groups organizing casual events.
- Clubs and community groups managing shared outings.
- People frustrated with fragmented planning tools or chat chaos.

Gatherly is not just an event invite platform—it's a planning engine, coordination hub, and AI assistant, designed to make group planning fun, fair, and frictionless.
