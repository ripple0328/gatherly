# Connected App Ecosystem Charter

## Grand goal

Build a gradually expanding family of focused apps that are valuable on their
own and become more useful together. A person establishes trusted profile facts
once and grants each app only the projection it needs. The ecosystem shares
explicit, versioned contracts—not a database, UI, or hidden dependency.

## App domains

- **SayMyName** owns person-authored names, name variants, pronunciation
  evidence and audio, reusable profile cards, and scoped profile grants.
- **Zonely** owns teams, membership, approved work-location context, timezone
  and availability evidence, and reachability decisions.
- **Gatherly** owns events, invitations, participation, proposals, preferences
  and votes, logistics, discussion, and event decisions.

Team membership and event participation stay distinct even when both reference
the same opaque `person_ref`. Location, timezone, and availability stay
separate facts with source and consent provenance.

## Contract-first workflow

1. Name the smallest domain primitive and its owning app.
2. Implement deterministic behavior inside that app's domain boundary.
3. Expose only a consent-scoped, versioned projection.
4. Add consumer-side adapters, contract fixtures, and unavailable-provider
   fallback without importing provider internals.
5. Evolve schemas additively and preserve unknown fields.
6. Extract a shared package only after a second production consumer proves the
   behavior is genuinely shared.

Gatherly is the source for event state and decisions. It may consume scoped
profile cards from SayMyName and, later, availability projections from Zonely,
but it must remain useful when either provider is unavailable and must never
copy their decision engines into its UI layer.
