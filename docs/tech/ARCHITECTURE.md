# Gatherly — Technical spec (high level)

This is **not implementation**. It defines the intended system at a spec level.

## Core entities (conceptual)
- User
- Event
- EventParticipant (RSVP)
- Proposal (time/location)
- Vote
- LogisticsItem (or Task/Item)
- Comment / Thread

## Key flows (MVP)
1) Create event → share invite link
2) Join event (OAuth or magic link; define anonymous policy)
3) RSVP (going/maybe/not going)
4) Propose time + vote
5) Propose location + vote + commute visualization support
6) Logistics: create items, assign owner, mark status
7) Discussion: threads + replies

## UI/component map (concept)
- `/events/:id`
  - Event header + details
  - RSVP box
  - Proposal & voting panels (time/location)
  - Logistics board
  - Commute map
  - Discussion forum

## Non-goals (for early phases)
- Perfect AI / heavy automation before MVP stability
- Too many event types before potluck flow is solid
- Betting on LiveView Native as the primary native strategy (not actively maintained)
