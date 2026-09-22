# BIGTUNE254 — Lovable Handoff

## CANON
- Product: BIGTUNE254 (BT)
- Product statement: **Big up the music. Discover the people. Move the culture.**
- Fan flow: Discover → Listen → Follow → Big Up → Participate
- Artist flow: Claim → Showcase → Publish → Grow → Understand → Monetize
- Primary navigation: Discover / Feed / Inbox / Profile
- BAD TUNE 🔥 is positive: hot-tune/high-energy endorsement, never dislike/downvote.

## DATABASE
Apply `supabase/migrations/0001_bigtune254_foundation.sql`.
Canonical Person/Profile and ArtistIdentity stay separate. A person may control multiple artist identities and have multiple roles.

## SECURITY
RLS is enabled across the foundation. User writes are ownership-scoped. Payments, ledger, allocations and audit writes are server-only in this baseline. Locked media cannot rely on frontend checks.

## SERVICES
Pesapal is the initial payment-rail target, but the domain stores provider-neutral payment state and references.

## EVENTS
Instrument actual events: track_played, track_completed, track_pulled_up, track_on_repeat, track_big_up, artist_followed, referral_opened, referral_converted, membership_started, subscription_paid, source_mention_detected, moderation and rights events. Raw observations remain distinct from derived intelligence.

## PAYMENTS
Never trust a frontend success boolean. Server-side verification must write the authoritative payment status and accounting records.

## RIGHTS
Keep ownership, administration, licence, territory, term, usage, royalty split and evidence separate. Do not make one Kenyan rights organization universal.

## INTELLIGENCE
Zazu Future Observatory pattern: observation → signal → context → evidence → intelligence. Do not replace it with a fake AI chatbot.

## SEEDING
Reference names already supplied by the canon: 9twan Studios, R3CS Records, BSX Records, Toxic Lyrikali, Mbogi Genje. Do not invent biographies, ownership or relationships.

## NEXT PASS IN LOVABLE
1. Connect Supabase Auth and the migration.
2. Replace prototype mock data with real queries.
3. Preserve the four-item mobile nav.
4. Add contextual artist controls inside Profile rather than a second dashboard.
5. Wire interaction events and append-only observations.
6. Build artist claim flow: search → claim → verify → review → connect links → publish.
7. Add event detail and external ticket links.
8. Keep black/gold/green, premium Nairobi street/culture, large media, fast interactions and minimal forms.

## DO NOT REINVENT
BAD TUNE 🔥 semantics, one BT membership, Person vs ArtistIdentity, provenance/uncertainty, financial/rights auditability, mobile navigation, or source observations vs canonical facts.
