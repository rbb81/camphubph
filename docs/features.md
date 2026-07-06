# Feature Prioritization: MVP vs. Future

Guiding principle: MVP must make the core loop work end-to-end — **discover a camp → learn about it → engage socially → save/plan a trip → come back and share your own experience.** Everything not load-bearing for that loop is deferred.

## MVP (v1)

| Feature | Why it's MVP |
|---|---|
| Splash, Onboarding, Login, Registration, Forgot Password | Baseline auth is required for any personalized/social feature. |
| Home Feed (friends' posts, community posts, recommended/nearby camps, suggested users) | Core retention loop; drives daily engagement. Trending/tips/events/news can start as simple, low-effort card types rather than fully separate systems. |
| Discover (category browsing) | Primary cold-start discovery path when a user has no follows/communities yet. |
| Search (camps, communities, users, locations, activities) | Essential utility; without it, users can't find anything specific. |
| Map (view camps/mountains/beaches/lakes + basic category filter) | Core differentiator vs. plain social apps; central discovery tool. |
| Camp Details | The anchor object for Discover, Search, Map, and Posts. |
| Create Post (text + multi-photo, optional camp tag, optional community tag) | Core content-generation feature; without it there's no user-generated supply. |
| Post interactions: Like, Comment, Share, Bookmark, Report | Baseline social mechanics; Report is required from day one for trust & safety. |
| Follow users | Powers the "friends' posts" part of Home Feed. |
| Communities: join, feed, post, comment, rules, pinned posts | Reddit/Facebook-Groups-style core; a differentiator versus pure Instagram-style apps. |
| Community moderators (basic: remove post/comment, ban member) | Minimum viable trust & safety for community health. |
| Reviews (rating, photos, pros/cons, tips, visit date) | Core trust signal for Camp Details; directly supports the Weekend Warrior persona. |
| Photo Gallery (per camp, per profile) | Natural aggregation of photos already uploaded via posts/reviews — low incremental cost once posts/reviews exist. |
| Profile (avatar, cover, bio, experience level, favorite styles, posts, photos, reviews, followers/following) | Identity is required for all social features. |
| Saved Camps & Wishlist | Lightweight, high-value planning primitive; precursor to full Trip Planner. |
| Trip Planner (basic): create a trip, add destination(s), set dates, simple checklist, status | Validates the planning use case without full collaboration complexity. |
| Notifications (likes, comments, follows, mentions, community activity) | Required to close the engagement loop and bring users back. |
| Settings (account, notification prefs, dark/light mode) | Baseline app hygiene. |
| Hashtags & Mentions | Low-cost, high-value for content discoverability and social connection. |

## Future (Phase 2+)

| Feature | Why it's deferred |
|---|---|
| Trip Planner: invite friends, collaborative checklists, shared itineraries | Adds real-time collaboration complexity; basic solo trip planning validates demand first. |
| Completed Trips (rich retrospective view, auto-linking to reviews/photos from that trip) | Nice-to-have layer on top of Trip Planner once trip history accumulates. |
| Advanced Map layers: trails, waterfalls, nearby attractions (beyond basic camps/mountains/beaches/lakes) | Requires richer geodata sourcing/curation; start with core location types. |
| Messages (direct messaging) | High infrastructure cost (real-time, moderation, spam/safety); social loop can work via comments/follows first. |
| Events (community meetups, RSVP) | Valuable but a distinct feature surface; can launch after Communities prove engagement. |
| Camping news feed | Content-supply-dependent (needs a curation or partner pipeline); not core to user-generated loop. |
| Trending destinations / algorithmic recommendations | Needs sufficient usage data to be meaningfully "trending" or "recommended" — cold-start problem. |
| Advanced moderation tooling (reports dashboard, auto-flagging, appeals) | Basic mod actions suffice at launch scale; invest further as community size grows. |
| "Find camping buddies" matching (beyond follow/search) | Distinct social-matching feature; validate organic buddy-finding via communities/posts first. |
| Offline mode (queued posts, offline map caching) | High engineering cost; graceful degradation (cached last-seen content) is enough for MVP. |
| Marketplace: bookings, gear sales, paid listings, payments | Explicitly out of scope until the community product is validated, per product vision. |

## Notes

- Several "Future" items are already implied structurally in MVP (e.g. Trip Planner's data model should anticipate "invited friends" even if the UI ships later) — this should be reflected when the Database Schema and App Architecture docs are produced.
- Feature sequencing after MVP should be re-prioritized based on real engagement data (which pillar drives retention) rather than fixed in advance.
