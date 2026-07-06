# Product Requirements Document (PRD)

## Product Name
**Camper** (working name; platform brand: CampHub PH)

## 1. Vision & Positioning

Camper is a camping-community-first mobile app for the Philippines. It combines:

| Inspiration | What we borrow |
|---|---|
| Reddit | Communities, discussions, upvote-style engagement, moderation |
| Instagram | Photo-first posts, profiles, follow graph, visual discovery |
| Facebook Groups | Group structure, membership, pinned posts, events |
| AllTrails | Location discovery, reviews, ratings, trip logging |
| Google Maps | Interactive map, geolocation, points of interest, filtering |

**Positioning statement:** For Filipino campers who want to discover new destinations, share their experiences, and connect with other campers, Camper is a mobile community app that combines social sharing, location discovery, and trip planning in one place — unlike generic social apps or static travel blogs, Camper is built entirely around the camping lifestyle.

**Strategic sequencing:** Build the best camping *community* app first. A marketplace (bookings, gear sales, paid guides) is an explicit future phase, not part of this build. Every product decision in this phase should optimize for engagement, trust, and content quality — not for monetization.

## 2. Goals & Success Metrics

### Business goals
- Become the default place Filipino campers go to find a destination and share their trip.
- Build a defensible content moat (reviews, photos, trip reports, community posts) before introducing commerce.
- Establish trusted local communities (regional, activity-based) that produce organic growth via sharing.

### Success metrics (MVP-era)
- **Activation:** % of new users who complete onboarding and either save a camp, join a community, or create a post within 7 days.
- **Engagement:** weekly active users (WAU), posts created per WAU, comments per post.
- **Discovery usage:** searches performed, map interactions, camp detail views per session.
- **Content supply:** number of camp reviews submitted, average rating count per camp, photo uploads per week.
- **Community health:** communities created, community join rate, posts-per-community, moderator actions taken (proxy for healthy moderation, not abuse volume).
- **Retention:** D7 / D30 retention, trip planner usage as a returning-user signal (trips are inherently future-dated, so this indicates return visits).

## 3. Target Market & Scope

- **Geography:** Philippines, nationwide. Camping culture spans mountains (e.g. Batangas, Rizal/Tanay, Cavite trail systems), beaches, lakes (e.g. Taal area), forests, rivers, and organized camping grounds/resorts.
- **Users:** Filipino campers across experience levels — first-timers researching a weekend trip, regular weekend warriors, overlanding/vanlife enthusiasts, and community organizers.
- **Device context:** Primarily mobile, often used with intermittent connectivity (campsites, mountains, rural areas). The app should degrade gracefully offline (cached content, queued actions) even though full offline support is not MVP.

## 4. Core Product Pillars

These map directly to the feature brief and are the organizing pillars for IA, navigation, and the feature list:

1. **Home Feed** — mixed social feed (friends, communities, recommendations, trending, tips, events, news, suggested users).
2. **Discover** — category-based browsing (Mountains, Beaches, Lakes, Forests, Rivers, Camping Grounds, Glamping, Overlanding, Pet Friendly, Family Friendly, Weekend Getaways, Budget Friendly).
3. **Search** — unified search across camps, locations, communities, users, provinces/cities, and activities.
4. **Map** — interactive map of camps, mountains, beaches, lakes, trails, waterfalls, and nearby attractions with category filters.
5. **Social** — posts, multi-photo uploads, trip reports, questions, gear/setup/location recommendations; like, comment, share, bookmark, report, follow, mentions, hashtags.
6. **Communities** — Reddit-style groups with feeds, rules, pinned posts, moderators, members, and search.
7. **Profile** — identity, camping experience, content history, social graph, saved/wishlist/completed trips, reviews.
8. **Trip Planner** — plan future trips: destinations, dates, invited friends, checklists, status tracking, itineraries.
9. **Reviews** — structured camp reviews (photos, ratings, pros/cons, tips, visit date).
10. **Photo Gallery** — per-camp and per-profile visual galleries sourced from posts and reviews.
11. **Notifications & Messages** — activity notifications and direct messaging to support the social graph.

## 5. Non-Functional Requirements

- **Performance:** feed and map should feel instant on mid-range Android devices (majority of PH smartphone market); lazy-load images, paginate feeds.
- **Connectivity resilience:** cache last-loaded feed/map tiles; queue posts/comments created offline for retry (best-effort, not a hard MVP requirement — see Features doc).
- **Accessibility:** support system font scaling, sufficient color contrast, screen-reader labels on interactive elements.
- **Theming:** full Dark Mode and Light Mode support from the design system.
- **Trust & safety:** report flow on posts/comments/users/reviews; community rules surfaced before posting; moderator tools scoped to their community.
- **Privacy:** location sharing (for map/nearby features) must be explicit opt-in with clear controls; users control who can message them.
- **Localization-readiness:** copy and content structures should not hardcode English-only assumptions, even if PH launch is English/Taglish first.

## 6. Out of Scope (this phase)

- Marketplace features: campsite booking/reservations, gear marketplace, paid listings, payments/checkout.
- Native web app (Flutter mobile — iOS + Android — is the initial and only target platform).
- Advanced monetization (ads, subscriptions, boosted posts).
- AI-generated trip recommendations (may be future work once content volume exists).

## 7. Assumptions, Risks, Open Questions

**Assumptions**
- Enough seed content (camps, reviews, photos) can be bootstrapped or imported to make Discover/Map/Search useful on day one, otherwise the app feels empty.
- Community-style moderation (volunteer mods) is viable at PH camping-community scale, similar to existing Facebook Groups this audience already uses.

**Risks**
- Cold-start problem: social + discovery apps need both content supply (locations/reviews) and demand (users) simultaneously.
- Location data quality: camp/trail locations in the Philippines are inconsistently mapped; may require a manual curation step before user-generated content scales.
- Migrating existing camping Facebook Group communities/users to a new app is a growth challenge, not just a product one.

**Open questions**
- Initial seed data source for camps/locations (manual curation vs. scraped/partner data vs. fully user-generated from day one)?
- Do we need a lightweight admin/moderation web console outside the Flutter app, or is in-app moderation sufficient for MVP?
- Should communities be open-join by default (Reddit-style) or approval-based (Facebook Group-style), or configurable per community?
