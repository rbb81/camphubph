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
- **Implemented (Phase 3, 2026-07-09):** shared by both account types — after a successful sign-in, the account's role (read from Supabase `user_metadata`, or an in-memory dummy-mode map when Supabase isn't configured) decides the destination: campers land on Home Feed (`/home`), camp owners land on the new Camp Owner Dashboard (`/owner-home`). No social sign-in yet.

## Registration
- **Regions:** form (center), footer link (bottom), optional interest-picker step after account creation.
- **Components:** name, email/phone, password fields; terms acknowledgment checkbox; primary "Create account" button; post-signup interest chips (Mountains/Beaches/Lakes/etc., multi-select) to seed Home Feed recommendations.
- **States:** default, validation error, loading, success (routes to interest picker, then Home).
- **Primary actions:** submit registration, select interests, skip interests.
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/register_screen.dart` gained an "I am a" `SegmentedButton` (Camper / Camp Owner, defaults to Camper) above the Full name field — the selected `UserRole` is stored on the account (`user_metadata.role` for real Supabase, an in-memory map keyed by email in dummy mode) and read back at login to route to the right destination. No interest-picker step yet; success still shows the "Check your email" confirmation panel regardless of account type. **Updated same day:** selecting Camp Owner also reveals a required "Campsite name" field (above Full name, which relabels to "Host name" for this account type) — both, plus the account's email, are stored alongside the role (`user_metadata.campsite_name`/`full_name` for real Supabase, the same in-memory dummy record) and carried into `AuthService.currentSession` on sign-in so the Camp Owner Dashboard can render the real business identity instead of a placeholder.

## Camp Owner Dashboard
- **Regions:** app bar, business-identity header, Reservations section, Messages section, floating "Add Reservation" action.
- **Components:** icon-badge business header (business name, "Hosted by \<name\> · \<email\>" line, "Camp Owner" chip — no cover photo/avatar/follower stats, deliberately distinct from the camper Profile header), reservation card (guest name, camp name, date range, status chip), Confirm/Decline buttons (pending only), Add Reservation form (guest name, camp dropdown, check-in/check-out date pickers, pending/confirmed toggle), message thread card (guest name, camp name, last-message preview, tap → chat thread).
- **States:** empty (no reservations yet / no messages yet), pending/confirmed/declined per reservation.
- **Primary actions:** confirm a pending reservation, decline a pending reservation, add a manual reservation (walk-in/phone booking), open a message thread and reply.
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/camp_owner_dashboard_screen.dart`, the post-login destination for accounts registered with the Camp Owner account type (also reachable directly from Landing's "Preview Camp Owner View (test)" button, bypassing register/login for manual testing — that path shows demo placeholder business info, "Daraitan Basecamp" / "Mang Rodel", since there's no real session). Lists sample reservations from `lib/data/sample_reservations.dart` (a fixed, sample-data-only list — no real `camps`/`reservations` Supabase schema, no `ownerId` linkage on `Camp`, no multi-owner account model) with immediate Confirm/Decline actions and an "Add Reservation" flow (`lib/screens/add_reservation_screen.dart`). **Updated same day:** the header now reads the campsite name, host name, and host email from `AuthService.instance.currentSession` (populated by the registration fields above) rather than being hardcoded, falling back to the demo placeholder only when there's no signed-in session. **Updated same day:** a Messages section below Reservations lists `lib/data/sample_message_threads.dart` threads (sorted by most recent activity), tapping one opens `lib/screens/message_thread_screen.dart` in owner mode to reply — see Messages above for the full scope/limits. Out of scope: payments/checkout, real booking-capacity/conflict enforcement, editing the business profile after registration, and any way to manage actual camp listings or switch back to a camper view — this stays a lightweight reservation *log*, not the deferred marketplace/booking feature described in `docs/PRD.md`.

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
- **Implemented (Phase 3, 2026-07-08; updated 2026-07-09):** friend-post like toggle and tap-through to Post Details are live; create-post FAB opens a real Create Post screen; recommended-camp cards tap through to Camp Details; community-post cards tap through to Community Feed. **Updated same day:** friend-post author avatar/name and the suggested-user card now tap through to Other User Profile (see Profile below), and the suggested-user Follow button is real (request → auto-approve). Share/bookmark/report remain stubbed.

## Discover
*(Visual mockup rendered above — see "camper_home_discover_mockup")*
- **Regions:** top bar (title, search icon), category grid, bottom tab bar.
- **Components:** category tile (icon + label): Mountains, Beaches, Lakes, Forests, Rivers, Camping Grounds, Glamping, Overlanding, Pet Friendly, Family Friendly, Weekend Getaways, Budget Friendly.
- **States:** default grid; tapping a tile → results list (filtered Camp Details cards) with secondary filters (distance, rating, price).
- **Primary actions:** select category, refine results, save/wishlist from a result card.
- **Implemented (Phase 3, 2026-07-08):** `lib/screens/discover_screen.dart` (category grid) and `lib/screens/camp_results_screen.dart` (filtered results list, sort by distance/rating/price + minimum-rating filter bottom sheet, tap-through to Camp Details).

## Search
- **Regions:** top search input (auto-focused on entry), scoped result tabs/sections, recent searches (empty-state).
- **Components:** search input with clear button, entity-type chips (Camps, Communities, Users, Locations, Activities), result rows per type (icon indicating type, title, subtitle).
- **States:** empty (recent/suggested searches), typing (live results), no results (helpful empty state, not a dead end), loaded.
- **Primary actions:** tap a result to route to its detail screen, filter by entity type.
- **Implemented (Phase 3, 2026-07-23):** `lib/screens/search_screen.dart` — opened from the search icon on Home/Discover/Communities (`Navigator` push, not a bottom-nav tab). Live, case-insensitive substring matching across camp name/location, community name/description, and person name/bio as you type (no debounce needed at this sample-data scale). All/Camps/Communities/People/Locations/Activities `ChoiceChip` selector; the "All" view groups matches into headed sections (capped to 3 each with a "See all in X" button), a specific facet shows its full list. Locations (derived from unique `Camp.location` strings) and Activities (the existing Discover categories) route into `CampResultsScreen` — extended with an optional `locationQuery` filter alongside its existing `category` filter — reusing that screen's sort/rating-filter UI rather than building new result screens. Not yet built: recent/suggested searches on the empty state (there's no persistence layer for it yet) — the empty state is a neutral prompt instead.

## Map
*(Visual mockup rendered above — see "camper_map_campdetails_mockup")*
- **Regions:** top bar (title, filter icon), full-bleed map canvas, bottom preview card (on pin tap), bottom tab bar.
- **Components:** map pins (color/icon-coded by category), filter chip row or bottom-sheet filter (multi-select toggles: camps, mountains, beaches, lakes, trails, waterfalls, attractions), location preview card (thumbnail, name, rating, distance).
- **States:** default (current-location-centered), filtered (subset of pins), pin-selected (preview card visible), location-permission-denied (fallback to manual region browse).
- **Primary actions:** toggle filters, tap pin, tap preview card → Camp Details, recenter to current location.
- **Implemented (Phase 3, 2026-07-10):** `lib/screens/map_screen.dart`, reached via the bottom nav "Map" tab (previously stubbed) and via Camp Details' "View on Map" button (which now centers/highlights the originating camp). Built with `flutter_map` + OpenStreetMap tiles + `latlong2` rather than the Google Maps integration originally named in `docs/PRD.md` — no API key or billing account required, works out of the box on web/Android/iOS. Renders one pin per `sampleCamps` entry (the `Camp` model gained a `coordinates` field with real approximate town-level PH coordinates, not exact geocoded points); tapping a pin shows a bottom-sheet preview card (name, location, rating) with a "View Details" button that pushes Camp Details. **Not built:** the filter chip row/category toggles, device geolocation or "current location" recentering (this is a static PH-wide map, not a "near me" map), marker clustering (unnecessary at only 12 pins), and search.

## Camp Details
*(Visual mockup rendered above — see "camper_map_campdetails_mockup")*
- **Regions:** hero image/carousel (with back and bookmark overlay), title block, quick actions row, tabs/sections (Overview, Photos, Reviews, Map), footer actions.
- **Components:** name, location, category tags, rating summary, "Save"/"Add to trip" buttons, photo gallery grid (preview, links to full Photo Gallery), review list preview (links to full Reviews), embedded mini-map, "Write a review" CTA.
- **States:** default, loading, no-reviews-yet (empty state encouraging first review).
- **Primary actions:** save, add to wishlist, add to trip, open full photo gallery, open full reviews, write a review, view on full map.
- **Implemented (Phase 3, 2026-07-08):** `lib/screens/camp_details_screen.dart` — hero header with back/bookmark overlay (Save toggle), title block (name, location, category tags, rating summary), Overview/Reviews/Photos/Map sticky tab bar. Reviews tab lists reviews with a working "Write a review" CTA (`lib/screens/write_review_screen.dart`) that appends the new review and recomputes the aggregate rating live; empty state shown when a camp has none. Photos tab is a simple grid aggregated from review photos (no separate lightbox — see Photo Gallery below). Map tab remains stubbed ("coming soon"), since the Map screen doesn't exist yet. **Updated 2026-07-09:** "Add to Trip" is implemented (see Trip Planner below). **Updated same day:** a full-width "Message Campsite" button opens a two-way chat thread with that camp (`lib/screens/message_thread_screen.dart`) — reuses an existing thread for the current guest/camp pair if one exists, otherwise starts a new empty one; see Messages below. **Updated 2026-07-10:** the Map tab is no longer stubbed — it's a real single-pin mini-map (same `flutter_map`/OpenStreetMap stack as the full Map screen, lightly interactive pan/zoom), and "View on Map" now pushes the full Map screen centered and highlighted on this camp; see Map above.

## Communities (tab landing)
- **Regions:** top bar (title, search icon), "Your communities" section, "Suggested communities" section, floating "create community" action, bottom tab bar.
- **Components:** community row/card (icon or cover image, name, private-community lock badge, member count, join button or "joined" state), create-community form (name, description, public/private setting).
- **States:** empty (no joined communities yet — shows suggestions prominently), populated.
- **Primary actions:** join/leave a community, tap through to Community Feed, search communities, create a new community (choosing public or private).
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/communities_screen.dart` — "Your communities"/"Suggested communities" sections, join/leave toggle, tap-through to Community Feed, lock badge on private communities. `lib/screens/create_community_screen.dart` — name/description form with a Public/Private `SegmentedButton`; a created community is auto-joined and inserted at the top of "Your communities". Private communities show a **Request to Join** button instead of **Join**: tapping it sends a request (button becomes **Requested**, tappable again to cancel), which auto-resolves to **Joined** after a simulated 2-second approval delay (no real backend/moderator review yet, and no admin-side "approve requests" UI). Private communities are still shown in Suggested (per product decision) rather than hidden.

## Community Feed
*(Visual mockup rendered above — see "camper_community_profile_mockup")*
- **Regions:** header (community name, member/mod count, back), sub-nav (Feed/Rules/Members tabs), pinned posts section (always on top), main feed, floating "new post" action.
- **Components:** pinned-post card (distinct visual treatment), regular post card, join/leave button (if not a member), moderator badge on relevant posts/authors.
- **States:** preview mode (not yet joined — read-only, join CTA prominent), member mode (full posting access), empty feed.
- **Primary actions:** join, post, comment, view rules, view members, view moderators (if authorized).
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/community_feed_screen.dart` — Feed/Rules/Members tabs, pinned posts rendered above regular posts with distinct styling, moderator badges, like toggle, join/leave (updates carry back to the Communities landing screen), and a lightweight compose sheet (caption only) gated on membership — tapping "new post" while not joined prompts to join first instead of showing a separate read-only visual mode. The app bar's join button follows the same Join → Request to Join/Requested → Joined states as the Communities landing screen for private communities. Feed/Rules/Members content itself is still visible in preview mode regardless of membership (public or private) — only posting is gated.
- **Comments implemented (Phase 3, 2026-07-24):** tapping a post's comment icon (previously `_comingSoon`) opens `lib/screens/community_post_details_screen.dart` — a like toggle, flat (non-threaded) comment list, and composer, mirroring Post Details' exact shape for a `CommunityFeedPost` instead of a `FriendPostItem` (kept as a separate screen since the two post types are unrelated models, per this app's no-shared-tile-widget convention). `CommunityFeedPost` gained a `comments: List<Comment>` field (reusing the existing generic `Comment` model), tracked independently of `commentCount` — same convention as `FriendPostItem`. Not yet built: photo attachments on community posts, moderator tools to edit rules/members or review join requests.

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
- **Implemented, narrower scope (Phase 3, 2026-07-09):** `lib/screens/notifications_screen.dart`, reached via the Home app bar bell icon (`lib/screens/home_screen.dart`, which now shows an unread-count `Badge`). Backed by `lib/models/app_notification.dart` (`NotificationType`: followRequest/like/comment) and `lib/data/sample_notifications.dart` — fixed seed data, not generated from live likes/comments during a session. Follow-request notifications model the current user being asked to follow *by* someone else (the reverse of the existing outgoing `FollowStatus`/`sampleOtherUsers` relationship) and are resolved entirely on the notification item itself, with inline Accept/Decline buttons. Like/comment notifications tap through to Post Details via a new `FriendPostItem.id` field; a lookup miss shows a snackbar instead of a broken screen. Not built: Today/This week/Earlier grouping (flat list only), routing to Profile/Community Feed/Trip Detail (only Post Details), contextual thumbnails, push notifications.

## Messages
- **Regions:** inbox (thread list) → thread (message list + composer).
- **Components (inbox):** thread row (avatar, name, last message preview, timestamp, unread badge).
- **Components (thread):** message bubbles, composer input, participant header (tap → Profile).
- **States:** empty inbox, unread threads, active thread, message sending/sent/failed.
- **Primary actions:** open a thread, send a message, view participant profile.
- **Implemented, narrower scope (Phase 3, 2026-07-09):** this general inbox UI described above (a dedicated Messages tab/screen with a thread list) is **not** built. What shipped instead is two-way chat reachable from context, covering both camper↔campsite and camper↔camper conversations: `lib/models/message_thread.dart` (`MessageThread`/`ChatMessage` — participants identified by name, not account id), sample data in `lib/data/sample_message_threads.dart` (shared mutable list, same pattern as Reservations/Trips — no real backend, no persistent read/unread state). `lib/screens/message_thread_screen.dart` is the one chat UI used by both cases: message bubbles (aligned by comparing the message sender's name to the current viewer's name), composer, no sending/sent/failed states. Reached from: Camp Details' "Message Campsite" button (camper → campsite), the Camp Owner Dashboard's Messages section (campsite owner → camper, listing only camp threads), and Other User Profile's "Message" button (camper → camper — see Profile below). **Updated same day:** generalized from a campsite-only model (which used a `senderIsOwner` bool) to the current name-based one specifically to support the camper↔camper case without a separate parallel implementation. Out of scope: unread badges, a general inbox/thread-list screen, tapping a message bubble to jump to that sender's profile, push notifications.

## Profile
*(Visual mockup rendered above — see "camper_community_profile_mockup")*
- **Regions:** cover photo, avatar (overlapping cover), identity block, stats row, action row (own vs. other-user variants), content tabs.
- **Components:** avatar, cover photo, name, bio, camping experience level, favorite camping styles (tags), followers/following counts, tabs: Posts / Photos / Reviews / Saved Camps / Wishlist / Completed Trips (own profile only shows Saved/Wishlist/Trip data; other users show only public content).
- **States:** own profile (edit button, access to Settings), other user's profile (follow/message buttons instead), loading.
- **Primary actions (own):** edit profile, open Settings, navigate to any content tab, open Trip Planner.
- **Primary actions (other):** follow/unfollow, message, view public tabs.
- **Implemented (Phase 3, 2026-07-24):** own-profile's Followers/Following stat taps (previously `_comingSoon` stubs) open `lib/screens/follow_list_screen.dart` (`FollowListScreen`, one screen parameterized by `FollowListType.followers`/`.following` rather than two files, since only the filter and title differ). Both lists are drawn from the existing 5-person `sample_other_users.dart` directory — there's no real follow graph and `UserProfile.followerCount`/`.followingCount` (482/213 for Ana) are just display ints with no backing identities, so building out bulk fake identities wasn't worth it (same scope-narrowing precedent as Notifications' fixed seed data). Following is real (filtered by the existing `FollowStatus.following`); Followers needed one new bit of seed data since the reverse relationship wasn't modeled at all — `FollowableUser` gained a `followsMe` bool (fixed seed: Jasmine Reyes, Ate Baby, and Rico P. are marked as following Ana). Each row reuses `OtherUserProfileScreen`'s exact follow state machine (tap Follow/Follow Back → Requested → auto-approves to Following after ~2s; tap Following to unfollow immediately, no confirmation) and taps through to that person's `OtherUserProfileScreen`. **Not built:** `OtherUserProfileScreen`'s own follower/following stat columns remain non-interactive (whose follow graph would a Followers/Following list even show, for someone who isn't the current user?) — deliberately out of scope, a bigger ask than closing the existing own-profile stub.
- **Implemented, narrower scope (Phase 3, 2026-07-09):** the "other user" variant shipped as a separate screen, `lib/screens/other_user_profile_screen.dart`, rather than a mode of the same `ProfileScreen` used for the current user (own-profile still has no cover photo — see the Profile screen's own note above; that part of this spec remains unbuilt). Shows identity block (avatar initials, name, bio, experience badge, favorite-style tags, follower/following counts — no cover photo, deliberately distinct from own-Profile's header) for another camper, backed by `lib/data/sample_other_users.dart` (`FollowableUser`, one entry per name currently appearing as a Home Feed post author or suggested user). Reached by tapping a friend-post author or a suggested-user card on Home Feed (`lib/screens/home_screen.dart`); falls back to a synthesized minimal profile if the tapped name isn't in the directory, same synthesized-fallback convention used elsewhere in this app (e.g. `home_screen.dart`'s `_openCamp`). Follow button uses the request → auto-approve-after-delay pattern already established for private-community joins (`communities_screen.dart`) — tap "Follow" → "Requested" → auto-flips to "Following" after ~2s (tap "Requested" again to cancel, tap "Following" to unfollow). Message button opens the same generalized `MessageThreadScreen` used for camper↔campsite messaging (see Messages below) — reuses an existing thread for that (camper, other user) pair or starts a new one. **Updated same day:** added the "public content" tabs from this spec — Posts and Reviews aggregate this user's entries from the existing `sample_feed.dart`/`sample_reviews.dart` lists (filtered by author name, no new per-user content data needed), Photos aggregates photo bytes from both (currently always empty in practice, since no sample post/review has real photo bytes — same as Camp Details' Photos tab). Posts tap through to Post Details, review camp names tap through to Camp Details. Saved Camps/Wishlist/Completed Trips tabs from the original spec are intentionally excluded (private to the owner). Not built: unfollow confirmation, a followers/following list for *this* (other) user — see the Profile section above for own-profile's Followers/Following, added 2026-07-24.

## Settings
- **Regions:** grouped list (Account, Notifications, Appearance, Privacy, Support, Log out).
- **Components:** list rows with icon/label/chevron or toggle; Appearance row includes Light/Dark/System selector.
- **States:** default; destructive actions (log out, delete account) require confirmation.
- **Primary actions:** edit account info, manage notification preferences, switch theme, manage privacy (location sharing, who can message me), log out.
- **Implemented, narrower scope (Phase 3, 2026-07-24):** `lib/screens/settings_screen.dart`, reached via Profile's gear icon (`tooltip: 'Settings'`, previously a `_comingSoon` stub). Account shows the signed-in email plus an "Edit Profile" row that reuses the existing `EditProfileScreen` rather than duplicating fields — any edit is carried back to `ProfileScreen` when Settings itself is closed. **Appearance's Light/Dark/System selector genuinely retheme the whole app live** via a new top-level `themeModeNotifier` (`lib/theme/app_theme.dart`) that `CamperApp`'s `MaterialApp` listens to — the first piece of global reactive app state in this codebase (everything else here is per-screen sample data). Notifications (push/likes & comments/follow requests/community activity) and Privacy (share location/allow messages from anyone) are session-only toggles backed by a new shared mutable `AppSettings` object (`lib/data/sample_settings.dart`) — they persist while navigating away and back, but reset on app restart and don't gate any real behavior yet (no backend to enforce them). Support rows (Help Center/Contact Support/About Camper) are cosmetic-only stubs. Log Out shows a confirmation dialog (this app's first `AlertDialog`) before clearing the session and returning to Landing. **Not built:** Delete Account (deliberately out of scope, confirmed with the user), a "who can message me" picker beyond a binary toggle, and any real persistence for the toggle preferences.

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
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/schedule_trip_screen.dart` (check-in/check-out date pickers, overlap conflict-check against `sampleTrips`) and `lib/screens/trip_planner_screen.dart` (Upcoming/Past list, computed from `endDate` vs. today, tapping a card opens Trip Detail) — reached from Camp Details' "Add to Trip" button and a new Profile header action. Not yet built: checklist, invite-friends, manual status tracking (status here is a computed Upcoming/Past grouping, not a stored field), and any auto-linking to the separate "Completed Trips" Profile tab.

### Trip Detail (sub-screen)
- **Regions:** header (trip name, status), destination(s) section, dates section, checklist section, (future) invited friends section.
- **Components:** destination card(s) (linking to Camp Details), date range picker, checklist items (add/check off), status stepper (Planning → Confirmed → Completed).
- **States:** editable (owner, upcoming trip), read-only (completed trip), shared/invited view (future phase).
- **Primary actions:** add/remove destination, set dates, add/check checklist items, change status, (future) invite friends.
- **Implemented (Phase 3, 2026-07-09):** `lib/screens/trip_details_screen.dart` — a single, simpler read-only-plus-cancel view (camp name/location, check-in/check-out dates, length of stay, "View Camp" linking to Camp Details, "Cancel Trip" removing it from `sampleTrips`). Not yet built: editing dates in place (canceling and re-scheduling is the only path today), destination cards for multi-camp trips, checklist, status stepper/change-status action, and invited-friends.

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
