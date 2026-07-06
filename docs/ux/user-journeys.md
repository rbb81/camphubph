# Complete User Journeys

End-to-end journeys through the screens defined in [information-architecture.md](../information-architecture.md) and [navigation-structure.md](../navigation-structure.md). Each maps to a persona from [personas.md](../personas.md).

## 1. First-time onboarding → first save (Weekend Warrior)

1. **Splash Screen** — app checks session, none found.
2. **Onboarding** — 3-slide carousel: "Discover camps near you", "Share your trips", "Join a community". Skippable.
3. **Registration** — email/phone + password, or social sign-in. Optional: pick 2-3 interests (mountains, beaches, glamping) to seed recommendations.
4. Lands on **Home Feed** — mostly recommended/nearby camps and trending destinations, since there's no follow graph yet.
5. Taps **Discover** → filters by "Weekend Getaways" → browses results.
6. Taps a card → **Camp Details** → reviews Photo Gallery and Reviews.
7. Taps **Save** → camp added to **Saved Camps** (accessible from Profile).
8. Returns to Home Feed; a "suggested users" card nudges her to follow a local camper.

**Success signal:** a saved camp + one follow within the first session (activation metric from the PRD).

## 2. Discover → review a completed trip (Trip Reporter)

1. From **Home Feed**, taps the **Create Post** floating action button.
2. **Create Post** — selects multiple photos, writes a trip report caption, tags the **Camp** (autocomplete search), optionally tags a **Community** ("Overlanding PH").
3. Publishes → post appears in **Home Feed** (to followers) and in the tagged **Community Feed**.
4. Later, taps his own **Profile** → **Photos** tab to confirm the gallery picked up the new images automatically.
5. Separately, visits the camp's **Camp Details** page → **Reviews** → writes a structured review (rating, pros/cons, tips, visit date, photos).
6. Review appears on Camp Details and contributes to that camp's Photo Gallery.

**Success signal:** a multi-photo post plus a structured review from the same trip — the core content-supply loop.

## 3. Join a community and post (Community Builder persona as a new member)

1. From **Search**, searches "Overlanding" → result includes the **Overlanding PH** community.
2. Taps into **Community Feed** (preview mode, not yet a member) → sees pinned rules, recent posts.
3. Taps **Join** → gains full posting access.
4. Reads **Rules** (surfaced automatically on first join).
5. Posts a question in the community feed.
6. Gets a comment reply → **Notifications** → taps through to **Post Details** to respond.

**Success signal:** join → post → receive engagement → return via notification (the community retention loop).

## 4. Plan a future trip with friends (Planner)

1. From **Discover** or **Map**, finds a candidate camp → **Camp Details** → adds to **Wishlist** instead of saving directly (aspirational, not yet decided).
2. A week later, opens **Profile → Wishlist**, decides to commit.
3. Taps "Add to trip" → creates a new entry in **Trip Planner**.
4. In **Trip Detail**: sets travel dates, adds the destination (already pre-filled from Wishlist), builds a checklist (tent, permits, food).
5. (Future phase) Invites friends from his follow list; they get a notification and can view the shared **Trip Detail**.
6. Trip status moves from "Planning" → "Confirmed" as the date approaches.
7. After the trip, status moves to "Completed" → trip appears under **Completed Trips**; prompted to write a **Review** for the camp.

**Success signal:** Wishlist → Trip Planner conversion, and Completed Trip → Review conversion (closes the full lifecycle loop).

## 5. Map-first exploration (Weekend Warrior, spontaneous)

1. Opens **Map** tab directly (already has location permission granted from onboarding).
2. Filters to show only "Lakes" and "Camping Grounds" within her viewport.
3. Taps a pin → preview card (name, rating, thumbnail) → **Camp Details**.
4. Compares 2-3 pins this way without leaving the map (preview card pattern avoids full navigation for quick comparisons).
5. Settles on one → **Save** directly from the preview card or full Camp Details page.

**Success signal:** map-driven discovery resulting in a save, validating Map as a first-class discovery surface, not just a secondary utility.

## 6. Global search across entity types

1. Taps **Search** from the top bar (available from Home/Discover/Map/Communities).
2. Types "Tanay" → sectioned results: Camps in Tanay, Province/City match ("Tanay, Rizal"), any Communities or Users mentioning Tanay.
3. Taps the City result → filtered Discover-style list of all camps in Tanay.
4. Alternatively types a username → jumps straight to that user's **Profile**.

**Success signal:** search resolves to the right entity type without the user needing to pre-select a filter first (default: blended results, refineable by type).

## 7. Handling a bad-actor post (trust & safety)

1. A user sees an off-topic/spam post in a **Community Feed**.
2. Taps the post's overflow menu → **Report** → selects a reason.
3. Report routes to the community's **Moderators**.
4. A moderator (Community Builder persona) reviews it from their moderation view → removes the post and/or bans the member.
5. Reporting user gets a lightweight acknowledgment notification (no detailed case status needed for MVP).

**Success signal:** report-to-resolution happens without requiring platform-level (non-community) intervention for routine cases.
