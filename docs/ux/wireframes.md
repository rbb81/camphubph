# Screen Wireframe Specs

Textual wireframe specifications for all 24 screens, covering layout regions, key components, states, and primary interactions. Platform: Flutter mobile (iOS + Android). Visual mockups for the highest-traffic screens (Home Feed, Discover, Map, Camp Details, Community Feed, Profile) were rendered separately in-conversation as reference; this document is the complete, reviewable spec for every screen including the ones not mocked up visually.

Legend: **Regions** (top to bottom or in layout order) → **Components** → **States/variants** → **Primary actions**.

---

## Splash Screen
- **Regions:** full-bleed logo/wordmark centered, nature-inspired background (subtle, not busy).
- **Components:** logo mark, app name, loading indicator (implicit, brief).
- **States:** checking session (default) → routes automatically, no user action.
- **Primary actions:** none (auto-transition to Onboarding or Home).

## Onboarding
- **Regions:** full-screen carousel (3 slides), page indicator dots, skip button (top-right), primary CTA (bottom).
- **Components:** illustration/photo per slide, headline, one-line subtext, "Next"/"Get started" button.
- **States:** slide 1/2/3; last slide CTA changes to "Get started".
- **Primary actions:** swipe/next, skip → Login.

## Login
- **Regions:** logo (small, top), form (center), footer links (bottom).
- **Components:** email/phone field, password field (with show/hide toggle), "Forgot password?" link, primary "Log in" button, divider, social sign-in buttons, "Don't have an account? Register" link.
- **States:** default, validation error (inline, field-level), loading (button spinner), auth error (banner above form).
- **Primary actions:** submit login, navigate to Forgot Password, navigate to Registration.

## Registration
- **Regions:** form (center), footer link (bottom), optional interest-picker step after account creation.
- **Components:** name, email/phone, password fields; terms acknowledgment checkbox; primary "Create account" button; post-signup interest chips (Mountains/Beaches/Lakes/etc., multi-select) to seed Home Feed recommendations.
- **States:** default, validation error, loading, success (routes to interest picker, then Home).
- **Primary actions:** submit registration, select interests, skip interests.

## Forgot Password
- **Regions:** form (center), back link.
- **Components:** email/phone field, "Send reset link" button, confirmation message state.
- **States:** default, submitted (shows confirmation, no user enumeration detail), error.
- **Primary actions:** submit, back to Login.

## Home Feed
*(Visual mockup rendered above — see "camper_home_discover_mockup")*
- **Regions:** top bar (logo, search icon, notifications icon), scrollable mixed feed, floating action button (Create Post), bottom tab bar.
- **Components:** post card (avatar, name, timestamp, location tag, image/carousel, like/comment/share/bookmark row), recommended-camp card (image, name, distance, rating, save button), community-post card (community badge, snippet), trending-destination card, tip card, event card, news card, suggested-user card (avatar, name, follow button).
- **States:** loading (skeleton cards), empty (new user — mostly recommendations, no friend posts yet), refreshing (pull-to-refresh), error (retry banner).
- **Primary actions:** like/comment/share/bookmark/report a post, tap through to Post Details/Camp Details/Profile/Community Feed, follow a suggested user, create a post.
- **Implemented (Phase 3, 2026-07-08; updated 2026-07-09):** friend-post like toggle and tap-through to Post Details are live; create-post FAB opens a real Create Post screen; recommended-camp cards tap through to Camp Details; community-post cards tap through to Community Feed. Share/bookmark/report and suggested-user follow remain stubbed.

## Discover
*(Visual mockup rendered above — see "camper_home_discover_mockup")*
- **Regions:** top bar (title, search icon), category grid, bottom tab bar.
- **Components:** category tile (icon + label): Mountains, Beaches, Lakes, Forests, Rivers, Camping Grounds, Glamping, Overlanding, Pet Friendly, Family Friendly, Weekend Getaways, Budget Friendly.
- **States:** default grid; tapping a tile → results list (filtered Camp Details cards) with secondary filters (distance, rating, price).
- **Primary actions:** select category, refine results, save/wishlist from a result card.
- **Implemented (Phase 3, 2026-07-08):** `lib/screens/discover_screen.dart` (category grid) and `lib/screens/camp_results_screen.dart` (filtered results list, sort by distance/rating/price + minimum-rating filter bottom sheet, tap-through to Camp Details). Search icon remains stubbed.

## Search
- **Regions:** top search input (auto-focused on entry), scoped result tabs/sections, recent searches (empty-state).
- **Components:** search input with clear button, entity-type chips (Camps, Communities, Users, Locations, Activities), result rows per type (icon indicating type, title, subtitle).
- **States:** empty (recent/suggested searches), typing (live results), no results (helpful empty state, not a dead end), loaded.
- **Primary actions:** tap a result to route to its detail screen, filter by entity type.

## Map
*(Visual mockup rendered above — see "camper_map_campdetails_mockup")*
- **Regions:** top bar (title, filter icon), full-bleed map canvas, bottom preview card (on pin tap), bottom tab bar.
- **Components:** map pins (color/icon-coded by category), filter chip row or bottom-sheet filter (multi-select toggles: camps, mountains, beaches, lakes, trails, waterfalls, attractions), location preview card (thumbnail, name, rating, distance).
- **States:** default (current-location-centered), filtered (subset of pins), pin-selected (preview card visible), location-permission-denied (fallback to manual region browse).
- **Primary actions:** toggle filters, tap pin, tap preview card → Camp Details, recenter to current location.

## Camp Details
*(Visual mockup rendered above — see "camper_map_campdetails_mockup")*
- **Regions:** hero image/carousel (with back and bookmark overlay), title block, quick actions row, tabs/sections (Overview, Photos, Reviews, Map), footer actions.
- **Components:** name, location, category tags, rating summary, "Save"/"Add to trip" buttons, photo gallery grid (preview, links to full Photo Gallery), review list preview (links to full Reviews), embedded mini-map, "Write a review" CTA.
- **States:** default, loading, no-reviews-yet (empty state encouraging first review).
- **Primary actions:** save, add to wishlist, add to trip, open full photo gallery, open full reviews, write a review, view on full map.
- **Implemented (Phase 3, 2026-07-08):** `lib/screens/camp_details_screen.dart` — hero header with back/bookmark overlay (Save toggle), title block (name, location, category tags, rating summary), Overview/Reviews/Photos/Map sticky tab bar. Reviews tab lists reviews with a working "Write a review" CTA (`lib/screens/write_review_screen.dart`) that appends the new review and recomputes the aggregate rating live; empty state shown when a camp has none. Photos tab is a simple grid aggregated from review photos (no separate lightbox — see Photo Gallery below). Map tab and "Add to Trip" remain stubbed ("coming soon"), since the Map and Trip Planner screens don't exist yet.

## Communities (tab landing)
- **Regions:** top bar (title, search icon), "Your communities" section, "Suggested communities" section, floating "create community" action, bottom tab bar.
- **Components:** community row/card (icon or cover image, name, private-community lock badge, member count, join button or "joined" state), create-community form (name, description, public/private setting).
- **States:** empty (no joined communities yet — shows suggestions prominently), populated.
- **Primary actions:** join/leave a community, tap through to Community Feed, search communities, create a new community (choosing public or private).
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/communities_screen.dart` — "Your communities"/"Suggested communities" sections, join/leave toggle, tap-through to Community Feed, lock badge on private communities. `lib/screens/create_community_screen.dart` — name/description form with a Public/Private `SegmentedButton`; a created community is auto-joined and inserted at the top of "Your communities". Search icon remains stubbed. Not yet built: any enforcement of private-community visibility or a request-to-join flow — the setting is currently just stored and displayed, not gated.

## Community Feed
*(Visual mockup rendered above — see "camper_community_profile_mockup")*
- **Regions:** header (community name, member/mod count, back), sub-nav (Feed/Rules/Members tabs), pinned posts section (always on top), main feed, floating "new post" action.
- **Components:** pinned-post card (distinct visual treatment), regular post card, join/leave button (if not a member), moderator badge on relevant posts/authors.
- **States:** preview mode (not yet joined — read-only, join CTA prominent), member mode (full posting access), empty feed.
- **Primary actions:** join, post, comment, view rules, view members, view moderators (if authorized).
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/community_feed_screen.dart` — Feed/Rules/Members tabs, pinned posts rendered above regular posts with distinct styling, moderator badges, like toggle, join/leave (updates carry back to the Communities landing screen), and a lightweight compose sheet (caption only) gated on membership — tapping "new post" while not joined prompts to join first instead of showing a separate read-only visual mode. Not yet built: comment threads on community posts (stubbed "coming soon"), photo attachments on community posts, moderator tools to edit rules/members.

## Post Details
- **Regions:** original post (full, expanded), comment thread, comment composer (sticky bottom).
- **Components:** full post content (all photos, full caption), author row (with follow button if not following), like/comment/share/bookmark/report row, threaded/flat comment list (author, text, like, reply), comment input.
- **States:** default, loading comments, empty comments ("be the first to comment"), deleted/removed post (moderation state).
- **Primary actions:** like/comment/share/bookmark/report, follow author, reply to a comment, tap author/camp/community mentions to navigate.
- **Implemented (Phase 3, 2026-07-08):** `lib/screens/post_details_screen.dart` — full post, like toggle, flat (non-threaded) comment list, comment composer. Not yet built: follow button, share/bookmark/report, moderation state, @mention navigation.

## Create Post
- **Regions:** header (cancel, "Post" submit button), photo/media picker, caption input, tag pickers (location, community), post-type shortcuts.
- **Components:** multi-image picker/reorder, caption textarea with @mention and #hashtag support, "Tag a camp" search field, "Post to a community" selector (optional, defaults to profile/followers only), post-type quick-select (trip report, question, gear tip, general).
- **States:** empty/draft, media-selected, uploading (progress), error (retry), success (returns to originating feed).
- **Primary actions:** attach photos, tag camp, tag community, publish, discard draft.
- **Implemented (Phase 3, 2026-07-08):** `lib/screens/create_post_screen.dart` — required caption, optional location, single photo picker (via `image_picker`), publishes a `FriendPostItem` to the top of Home Feed. Not yet built: multi-image/reorder, @mention/#hashtag, camp/community tagging, post-type quick-select, upload progress (no Storage backend yet — photo stays in-memory).

## Notifications
- **Regions:** top bar (title, mark-all-read), chronological list, grouped by recency (Today/This week/Earlier).
- **Components:** notification row (actor avatar, action description, timestamp, contextual thumbnail, unread indicator).
- **States:** empty ("no notifications yet"), unread (visual emphasis), read.
- **Primary actions:** tap → route to the relevant Post Details/Profile/Community Feed/Trip Detail, mark all as read.

## Messages
- **Regions:** inbox (thread list) → thread (message list + composer).
- **Components (inbox):** thread row (avatar, name, last message preview, timestamp, unread badge).
- **Components (thread):** message bubbles, composer input, participant header (tap → Profile).
- **States:** empty inbox, unread threads, active thread, message sending/sent/failed.
- **Primary actions:** open a thread, send a message, view participant profile.

## Profile
*(Visual mockup rendered above — see "camper_community_profile_mockup")*
- **Regions:** cover photo, avatar (overlapping cover), identity block, stats row, action row (own vs. other-user variants), content tabs.
- **Components:** avatar, cover photo, name, bio, camping experience level, favorite camping styles (tags), followers/following counts, tabs: Posts / Photos / Reviews / Saved Camps / Wishlist / Completed Trips (own profile only shows Saved/Wishlist/Trip data; other users show only public content).
- **States:** own profile (edit button, access to Settings), other user's profile (follow/message buttons instead), loading.
- **Primary actions (own):** edit profile, open Settings, navigate to any content tab, open Trip Planner.
- **Primary actions (other):** follow/unfollow, message, view public tabs.

## Settings
- **Regions:** grouped list (Account, Notifications, Appearance, Privacy, Support, Log out).
- **Components:** list rows with icon/label/chevron or toggle; Appearance row includes Light/Dark/System selector.
- **States:** default; destructive actions (log out, delete account) require confirmation.
- **Primary actions:** edit account info, manage notification preferences, switch theme, manage privacy (location sharing, who can message me), log out.

## Saved Camps
- **Regions:** header, grid/list of saved camps, empty state.
- **Components:** camp card (thumbnail, name, rating, quick "remove" action).
- **States:** empty ("nothing saved yet — start exploring", CTA to Discover), populated.
- **Primary actions:** tap through to Camp Details, remove from saved, add to trip.

## Wishlist
- **Regions:** header, list of wishlist camps, empty state.
- **Components:** camp card (thumbnail, name, note/tag for "why", "Move to trip" action).
- **States:** empty ("dream up your next trip", CTA to Discover/Map), populated.
- **Primary actions:** tap through to Camp Details, convert to a Trip Planner entry, remove.

## Trip Planner
- **Regions:** header ("+ New trip"), trips grouped by status (Planning, Confirmed/Upcoming, Completed).
- **Components:** trip card (destination thumbnail, name, dates, status badge, participant avatars).
- **States:** empty ("plan your first trip"), populated, filtered by status tab.
- **Primary actions:** create a trip, tap through to Trip Detail.

### Trip Detail (sub-screen)
- **Regions:** header (trip name, status), destination(s) section, dates section, checklist section, (future) invited friends section.
- **Components:** destination card(s) (linking to Camp Details), date range picker, checklist items (add/check off), status stepper (Planning → Confirmed → Completed).
- **States:** editable (owner, upcoming trip), read-only (completed trip), shared/invited view (future phase).
- **Primary actions:** add/remove destination, set dates, add/check checklist items, change status, (future) invite friends.

## Completed Trips
- **Regions:** header, list of past trips.
- **Components:** trip card (destination, dates, thumbnail from that trip's photos/reviews if available), "write a review" prompt if not yet reviewed.
- **States:** empty (no completed trips yet), populated.
- **Primary actions:** tap through to Trip Detail (read-only), write a review for a completed destination.

## Reviews
- **Regions (list view, from Profile):** header, list of the user's written reviews.
- **Regions (write/edit view, from Camp Details):** camp header (context), structured form.
- **Components:** star/numeric rating input, photo picker, pros list input, cons list input, tips textarea, visit-date picker, submit button.
- **States:** list — empty ("no reviews yet"); form — draft, submitting, success, validation error (rating required).
- **Primary actions (list):** tap a review to edit/delete.
- **Primary actions (form):** set rating, add photos, add pros/cons, set visit date, submit.
- **Implemented (Phase 3, 2026-07-08):** the write/edit-from-Camp-Details form is live at `lib/screens/write_review_screen.dart` — star rating (required, validates on submit), add/remove pros and cons as chips, optional tips textarea, visit-date picker, optional single photo (`image_picker`). Not yet built: the list view of a user's own written reviews from Profile (Profile's Reviews tab is still `_comingSoon`-stubbed), and editing/deleting an existing review.

## Photo Gallery
- **Regions:** header (context: camp name or profile name), grid of photos, lightbox on tap.
- **Components:** photo grid (uniform thumbnails), lightbox (full image, swipe between photos, source post/review link, uploader credit).
- **States:** empty (only for a brand-new camp/profile with no content yet), populated, lightbox open.
- **Primary actions:** tap to open lightbox, swipe through photos, tap through to the source Post Details or Review.
- **Not yet implemented:** Camp Details' Photos tab currently shows a plain grid of review photos with no lightbox, swipe, or source-link — this dedicated full-screen gallery is still spec-only.

---

## Design system application notes

- **Vivid blue palette:** vivid blue (`AppColors.brand`) as the primary accent with a deep navy (`AppColors.brandStrong`) for the auth split-panel and dark-mode surfaces, gold (`AppColors.gold`) as a secondary accent for ratings/highlights, neutral cool-gray/blue-white for structure — consistent across all screens above. Replaces the earlier teal/amber nature palette (updated 2026-07-06 to match a Kidtopia-style reference).
- **App icon:** cartoon-style A-frame tent (rounded outline, white canvas, gold door and flag) in this blue/gold palette — implemented via `flutter_launcher_icons` from source SVGs in `assets/icon/`, generated for Android (adaptive icon), iOS, and web.
- **Dark/Light mode:** every screen must be checked in both; photo-heavy screens (Home Feed, Discover, Camp Details, Photo Gallery) rely most on surface/border tokens rather than hardcoded colors.
- **Empty states:** every list-based screen (Saved Camps, Wishlist, Trip Planner, Completed Trips, Reviews, Notifications, Messages, Community feeds) has a defined empty state — this is a first-class design requirement, not an afterthought, since a content-cold-start app will show these often in early usage.
- **Bottom tab bar consistency:** Home, Discover, Map, Communities, Profile persist across all tab-level screens; all other screens above are reached via push/modal as defined in [navigation-structure.md](../navigation-structure.md).
