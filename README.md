# Camper

Camper is a camping-community app for the Philippines — discover camps, share trips, and connect with other campers. Built with Flutter so the same codebase targets web, Android, and iOS. Product/UX planning docs live in [`docs/`](docs/).

Currently implemented (see [docs/ux/wireframes.md](docs/ux/wireframes.md) for the full per-screen spec and status): registration, login, and forgot-password screens (responsive, web + mobile) wired to Supabase Auth; a Home Feed (mixed feed, create post, likes/comments, bottom tab bar); Discover → Camp Results → Camp Details (with a working Reviews/write-a-review flow); Communities → Community Feed, plus creating a new community with a public/private setting; and a Profile screen (own-profile view + Edit Profile form). All content screens render from static sample data (`lib/data/`) — there's no real Supabase schema for posts/camps/reviews/communities/profiles yet.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A Supabase project (create one at [supabase.com](https://supabase.com) if you don't have one yet)
- Chrome (for running/debugging the web target)

## Run locally (web)

1. Get packages:

   ```bash
   flutter pub get
   ```

2. Create your local env file from the example:

   ```bash
   cp .env.example .env
   ```

3. Fill in `.env` with your Supabase project's values (Supabase dashboard → Project Settings → API):

   ```
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

4. Run on Chrome, passing the env file in at build time:

   ```bash
   flutter run -d chrome --dart-define-from-file=.env
   ```

5. Once it opens, click **Create your account** to reach `/#/register`, or **Log in** to reach `/#/login` (which links to `/#/forgot-password`).

Values are read via `String.fromEnvironment` in [`lib/config/env.dart`](lib/config/env.dart) — if you skip `--dart-define-from-file` (or don't have a Supabase project yet), auth screens fall back to dummy data instead of calling Supabase, so you can still click through registration/login/forgot-password. See **Dummy auth mode** below.

## Run on Android / iOS

Same steps, just target a device/simulator instead of Chrome:

```bash
flutter run -d <device-id> --dart-define-from-file=.env
```

Run `flutter devices` to list available targets.

## Dummy auth mode

[`lib/services/auth_service.dart`](lib/services/auth_service.dart) wraps every Supabase Auth call. When `Env.isConfigured` is `false` (no `SUPABASE_URL`/`SUPABASE_ANON_KEY` passed via `--dart-define-from-file`), it skips Supabase entirely and returns success after a short fake delay instead — so registration, login, and forgot-password all just work without a real backend:

- Register / forgot-password show the same "Check your email" success panel they would with real Supabase (no email is actually sent).
- Login succeeds with **any** email/password that pass client-side validation, and navigates to `/home`.

The moment real credentials are provided, `AuthService` automatically switches back to calling the real Supabase SDK — no code changes needed, no flag to flip.

## Debugging auth

- Sign-ups call `AuthService.instance.signUp` (see [`lib/screens/register_screen.dart`](lib/screens/register_screen.dart)); login calls `.signIn` ([`lib/screens/login_screen.dart`](lib/screens/login_screen.dart)); forgot-password calls `.resetPassword` ([`lib/screens/forgot_password_screen.dart`](lib/screens/forgot_password_screen.dart)) — all routed through [`lib/services/auth_service.dart`](lib/services/auth_service.dart). All three screens share the responsive layout and error/loading UI in [`lib/widgets/auth_layout.dart`](lib/widgets/auth_layout.dart).
- When Supabase *is* configured: its default email-confirmation flow applies — after signing up, check **Authentication → Users** in the Supabase dashboard to see the new (unconfirmed) user, and **Authentication → Logs** if a confirmation or password-reset email doesn't show up.
- To skip email confirmation while developing against real Supabase, toggle it off under **Authentication → Providers → Email → Confirm email** in the Supabase dashboard — otherwise login will fail for an unconfirmed account with an "Email not confirmed" error.
- Supabase itself is initialized once in [`lib/main.dart`](lib/main.dart), only when configured — so `flutter run` without `--dart-define-from-file` never touches the Supabase SDK at all, it just uses the dummy fallback above.
- After a successful login, the app navigates to `/home` and clears the auth screens from the back stack.

## Home Feed

[`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) is the post-login destination — a mixed feed (friend posts, recommended camps, community posts, tips, suggested users) with a top bar (search/notifications, both stubbed) and a bottom tab bar. **Home** and **Profile** are implemented; **Discover**, **Map**, **Communities** still show a "coming soon" message, per [docs/ux/wireframes.md](docs/ux/wireframes.md).

There's no `posts`/`camps` schema in Supabase yet, so the feed renders from static sample data in [`lib/data/sample_feed.dart`](lib/data/sample_feed.dart) (modeled by [`lib/models/home_feed_item.dart`](lib/models/home_feed_item.dart)) rather than a real query — swap that out once the database schema exists.

## Profile

[`lib/screens/profile_screen.dart`](lib/screens/profile_screen.dart) is reached by tapping **Profile** in Home's bottom tab bar (`/profile` route). It's the own-profile view only — cover photo + overlapping avatar, bio, experience-level badge, favorite camping-style tags, follower/following counts, and a sticky tab bar (Posts / Photos / Reviews / Saved Camps / Wishlist / Completed Trips). Tapping into an individual tab item still shows a "coming soon" message.

There's no `profiles` schema in Supabase yet either, so this renders from static sample data in [`lib/data/sample_profile.dart`](lib/data/sample_profile.dart) (modeled by [`lib/models/profile.dart`](lib/models/profile.dart)).

The cover photo intentionally bleeds edge-to-edge under the status bar (no `AppBar`, `SafeArea(top: false)` on the body) — an `AnnotatedRegion<SystemUiOverlayStyle>` makes the status bar itself transparent with light icons so it blends with the cover instead of showing as an opaque bar on top of it. The back/settings icon buttons are still individually wrapped in their own `SafeArea` so they land below a notch/status bar rather than under it.

Tapping **Edit Profile** opens [`lib/screens/edit_profile_screen.dart`](lib/screens/edit_profile_screen.dart), a real working form — name/bio text fields, an experience-level selector, and favorite-style tag chips, plus avatar/cover photo pickers via [`image_picker`](https://pub.dev/packages/image_picker). There's no Supabase Storage configured yet, so picked images are only held in memory for the current session (not uploaded anywhere) and are lost on reload.

## Testing

### 1. Unit / widget tests

No device, emulator, or Supabase config needed — these run against the widget tree directly.

```bash
flutter test
```

To run a single file:

```bash
flutter test test/register_screen_test.dart
```

Covers:
- [`test/register_screen_test.dart`](test/register_screen_test.dart) — required-field errors, invalid email format, mismatched password/confirm password, a fully valid submit succeeding via the dummy auth fallback, account-type toggle defaults to Camper and a Camp Owner submission still succeeds, Campsite name only appears (and Full name relabels to Host name) for Camp Owner, submitting Camp Owner without a campsite name shows a validation error
- [`test/login_screen_test.dart`](test/login_screen_test.dart) — required-field errors, invalid email format, valid submit navigating to `/home` via the dummy auth fallback, navigation to `/forgot-password` and `/register`, a camp-owner account routes to `/owner-home` instead
- [`test/auth_service_test.dart`](test/auth_service_test.dart) — pure unit tests for the dummy-mode role round trip: sign up as camp owner/camper then sign in returns an `AuthResult` with the matching `UserRole`, an unregistered email defaults to camper, a campsite name round-trips through sign-in and populates `AuthService.currentSession`
- [`test/camp_owner_dashboard_screen_test.dart`](test/camp_owner_dashboard_screen_test.dart) — with no signed-in session renders demo placeholder business info (distinct from camper Profile — no Followers/Following); with a signed-in session renders the real campsite/host name and email; seeded reservations render; Confirm/Decline flips a pending reservation's status and updates `sampleReservations`; Add Reservation appends a new card; seeded message threads render with a last-message preview; opening a thread and replying as owner updates `sampleMessageThreads` and the preview
- [`test/add_reservation_screen_test.dart`](test/add_reservation_screen_test.dart) — required-field validation, a fully valid submit pops a `Reservation` and appends it to `sampleReservations`
- [`test/forgot_password_screen_test.dart`](test/forgot_password_screen_test.dart) — empty/invalid email validation, valid submit succeeding via the dummy auth fallback, navigation back to `/login`
- [`test/home_screen_test.dart`](test/home_screen_test.dart) — app bar/bottom tab bar render, mixed feed content renders, tap-through to Discover/Communities/Post Details/Camp Details/Create Post, "coming soon" for Map/search/notifications, friend-post author and suggested-user tap-through to Other User Profile, requesting to follow a suggested user shows Requested then Following after auto-approval
- [`test/other_user_profile_screen_test.dart`](test/other_user_profile_screen_test.dart) — identity block renders; Follow requests then auto-approves to Following; canceling a pending request reverts to Follow; Message reuses an existing thread or starts a new empty one
- [`test/discover_screen_test.dart`](test/discover_screen_test.dart) — category grid renders, tapping a category opens Camp Results
- [`test/camp_results_screen_test.dart`](test/camp_results_screen_test.dart) — filtered results render, sort/rating filter sheet, tap-through to Camp Details, empty-filter state
- [`test/camp_details_screen_test.dart`](test/camp_details_screen_test.dart) — identity block renders, bookmark toggle, Reviews tab (populated and empty states), writing a review updates the aggregate rating/count, Add to Trip pushes Schedule Trip and shows a confirmation, Message Campsite reuses an existing thread or starts a new empty one
- [`test/write_review_screen_test.dart`](test/write_review_screen_test.dart) — rating-required validation, pro/con chip add/remove, a fully valid submit
- [`test/message_thread_screen_test.dart`](test/message_thread_screen_test.dart) — camper view of a camp thread shows the camp name as the title, owner view shows the guest name, a user-to-user thread shows the other person's name; empty-thread state; sending a message appends it, clears the composer, and updates `sampleMessageThreads`
- [`test/create_post_screen_test.dart`](test/create_post_screen_test.dart) — caption validation, optional location, a valid submit
- [`test/post_details_screen_test.dart`](test/post_details_screen_test.dart) — post/comment thread renders, like toggle, adding a comment
- [`test/communities_screen_test.dart`](test/communities_screen_test.dart) — Your/Suggested sections render, join/request-to-join/leave, private-community badge, tap-through to Community Feed, create-community flow inserts at the top
- [`test/community_feed_screen_test.dart`](test/community_feed_screen_test.dart) — pinned posts, Rules/Members tabs, like toggle, compose (gated on membership), request-to-join → approval flow
- [`test/create_community_screen_test.dart`](test/create_community_screen_test.dart) — name/description validation, Public/Private toggle, cancel pops null
- [`test/schedule_trip_screen_test.dart`](test/schedule_trip_screen_test.dart) — missing-dates validation, an overlapping date range shows a named conflict error, a valid non-conflicting range pops a `Trip` and appends it to `sampleTrips`
- [`test/trip_planner_screen_test.dart`](test/trip_planner_screen_test.dart) — seeded trips grouped into Upcoming/Past and sorted by date, tap-through to Trip Details, canceling a trip removes it and shows a confirmation snackbar, empty state
- [`test/trip_details_screen_test.dart`](test/trip_details_screen_test.dart) — camp/dates/length-of-stay render, View Camp opens Camp Details for the same camp, Cancel Trip removes it from `sampleTrips` and pops `true`
- [`test/trip_test.dart`](test/trip_test.dart) — pure unit tests for `Trip.rangesOverlap`/`Trip.findConflict`'s date-range overlap logic
- [`test/profile_screen_test.dart`](test/profile_screen_test.dart) — identity block and tab labels render, settings/follower-stat "coming soon" messages, switching tabs shows matching sample content, Edit Profile and Trip Planner navigation
- [`test/edit_profile_screen_test.dart`](test/edit_profile_screen_test.dart) — form pre-populates from the passed profile, name validation, style-chip toggling, avatar/cover picker buttons don't crash, Save pops with the edited profile
- [`test/widget_test.dart`](test/widget_test.dart) — landing screen → registration navigation, "Preview Camp Owner View (test)" → Camp Owner Dashboard navigation

### 2. Maestro end-to-end flows

Flows live in [`.maestro/`](.maestro/) and drive a real, running build on a device/emulator/simulator (`appId: com.camphubph.camper`).

**Install Maestro** (skip if already installed — check with `maestro --version`):

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

On Windows, run that inside WSL or Git Bash, then make sure `~/.maestro/bin` (or wherever it installed to) is on your `PATH` — reopen your terminal afterwards so `maestro` resolves.

**Run a flow:**

1. Start an Android emulator or iOS simulator (or plug in a physical device), then install/run the app on it:

   ```bash
   flutter devices              # confirm the device shows up
   flutter run -d <device-id> --dart-define-from-file=.env
   ```

2. Leave that running, and in a second terminal run a flow against it:

   ```bash
   maestro test .maestro/register_validation.yaml
   ```

   Only checks client-side validation — no Supabase call is made, so this one works even without a configured `.env`.

   ```bash
   maestro test .maestro/register_happy_path.yaml
   ```

   Fills a valid form and submits. Works either way: without `--dart-define-from-file` it exercises the dummy auth fallback (always succeeds); with real Supabase credentials it exercises an actual `signUp` call. Both land on the same "Check your email" state.

   ```bash
   maestro test .maestro/login_validation.yaml
   maestro test .maestro/forgot_password_validation.yaml
   ```

   Both are validation-only (no auth call at all), so they work regardless of configuration.

   ```bash
   maestro test .maestro/home_smoke.yaml
   ```

   Home is only reachable after logging in. The flow's default credentials (`dummy@example.com` / `dummy-password`) work as-is against a build without `--dart-define-from-file`, since the dummy auth fallback accepts any credentials. Against a build with real Supabase credentials, override with a pre-existing, **email-confirmed** test account instead: `maestro test -e MAESTRO_TEST_EMAIL=you@example.com -e MAESTRO_TEST_PASSWORD=yourpassword .maestro/home_smoke.yaml`. All of the flows below share this same login requirement and credential-override mechanism.

   ```bash
   maestro test .maestro/profile_smoke.yaml
   maestro test .maestro/edit_profile_flow.yaml
   ```

   `profile_smoke.yaml` logs in, taps into Profile from the bottom nav, and checks a tab switch; `edit_profile_flow.yaml` additionally opens Edit Profile, changes the name field, saves, and confirms the change is reflected back on Profile.

   ```bash
   maestro test .maestro/discover_smoke.yaml
   maestro test .maestro/camp_details_smoke.yaml
   maestro test .maestro/write_review_flow.yaml
   maestro test .maestro/schedule_trip_flow.yaml
   ```

   `discover_smoke.yaml` taps a category and checks the filtered results. `camp_details_smoke.yaml` continues into a camp's details and its Reviews tab. `write_review_flow.yaml` opens Write a Review and checks the rating-required validation error (the star-rating buttons have no text/tooltip label, so Maestro's text-based taps can't pick a star — the happy path is covered by the widget/chromedriver tests instead). `schedule_trip_flow.yaml` opens Schedule Trip from "Add to Trip", checks the missing-dates validation error, then drives the Material date picker via its "Switch to input" toggle to schedule a real date range and confirms it.

   ```bash
   maestro test .maestro/message_campsite_flow.yaml
   ```

   Opens a camp with no seeded conversation, taps "Message Campsite" to start a brand-new empty thread, sends a message, and confirms it appears in the conversation.

   ```bash
   maestro test .maestro/follow_and_message_flow.yaml
   ```

   Requests to follow the Home Feed's suggested user, taps through to their Other User Profile, and messages them via the same chat UI as campsite messaging.

   ```bash
   maestro test .maestro/communities_smoke.yaml
   maestro test .maestro/community_feed_smoke.yaml
   maestro test .maestro/create_community_flow.yaml
   ```

   `communities_smoke.yaml` checks the Your/Suggested sections and joins a suggested community. `community_feed_smoke.yaml` opens an already-joined community, checks its Rules/Members tabs, and composes a post. `create_community_flow.yaml` checks name/description validation and the Public/Private toggle, then creates a community.

   ```bash
   maestro test .maestro/create_post_flow.yaml
   maestro test .maestro/post_details_flow.yaml
   ```

   `create_post_flow.yaml` checks the caption-required validation error, then publishes a post (skipping the photo picker — it opens the real native gallery UI, which isn't reliably drivable). `post_details_flow.yaml` opens a seeded post and adds a comment.

   ```bash
   maestro test .maestro/trip_planner_smoke.yaml
   maestro test .maestro/trip_details_flow.yaml
   ```

   `trip_planner_smoke.yaml` opens Trip Planner from Profile, checks the seeded trips render under Upcoming/Past, then opens one and checks its details render. `trip_details_flow.yaml` continues further — cancels that trip and confirms it's removed from the list.

   ```bash
   maestro test .maestro/camp_owner_register_flow.yaml
   maestro test .maestro/camp_owner_dashboard_smoke.yaml
   ```

   `camp_owner_register_flow.yaml` is `register_happy_path.yaml` with the new "Camp Owner" account-type segment selected before submitting, including the required Campsite name field. `camp_owner_dashboard_smoke.yaml` registers a Camp Owner account (with a campsite name), backs out to Landing, logs back in with the same credentials, and confirms it lands on the Camp Owner Dashboard showing that real campsite/host info (not the demo placeholder) and the Messages section, rather than Home — self-contained since there's no pre-seeded owner account, unlike `home_smoke.yaml`'s credential-override approach.

   ```bash
   maestro test .maestro/camp_owner_reservations_flow.yaml
   ```

   Uses the Landing screen's "Preview Camp Owner View (test)" shortcut to skip register/login entirely, confirms a seeded pending reservation, then adds a new reservation via the FAB form and confirms it appears in the list.

3. To run every flow in the folder at once:

   ```bash
   maestro test .maestro/
   ```

Maestro doesn't target Chrome/web — these flows need an Android or iOS target. These flows haven't been run against a live emulator in this environment (none was available here) — verify locally before relying on them in CI.

### 3. Web end-to-end tests (Flutter driver + chromedriver)

Maestro can't drive Flutter Web — it renders to a `<canvas>`, not a normal DOM Maestro's web support can inspect. For a web equivalent of the Maestro flows above, use Flutter's own `integration_test` package driven through `flutter drive`, which controls a real Chrome window via chromedriver. This has been verified working end-to-end in this repo.

1. Install a `chromedriver` build that matches your local Chrome version:

   ```bash
   google-chrome --version   # or check chrome://version on Windows
   ```

   Download the matching build from the [Chrome for Testing dashboard](https://googlechromelabs.github.io/chrome-for-testing/) (pick the version closest to yours — chromedriver only needs to match the Chrome major version) and unzip `chromedriver.exe`/`chromedriver` somewhere on your `PATH`.

2. Start chromedriver on port 4444 (leave it running in its own terminal):

   ```bash
   chromedriver --port=4444
   ```

3. In another terminal, run a flow. Every file below has been run against a real Chrome window in this environment (chromedriver 149.x) — **all 22 currently pass**:

   ```bash
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/<file>.dart -d chrome
   ```

   | File | Covers |
   | --- | --- |
   | `landing_test.dart`, `register_test.dart`, `login_test.dart`, `forgot_password_test.dart` | Boot the full app via `app.main()` (not a pumped single screen, unlike the rest of this table). `landing_test.dart` checks the brand/CTA, the "Log in" link, and the "Preview Camp Owner View (test)" button reaching the dashboard. The other three run **without** `--dart-define-from-file` on purpose — each asserts empty-form validation, then a fully valid submit succeeding via the dummy auth fallback (Supabase intentionally left unconfigured). `register_test.dart` also submits with the Camp Owner account-type segment selected (including the Campsite name field); `login_test.dart` also signs up a Camp Owner account (with a campsite name) directly via `AuthService` then logs in through the UI, confirming it routes to the Camp Owner Dashboard and renders the real campsite/host info instead of the demo placeholder. |
   | `home_test.dart` | Feed renders; search/create-post/tab-bar "coming soon" messages; like toggle; tap-through to Post Details, Camp Details, Discover, Communities; tapping a friend-post author opens Other User Profile. |
   | `camp_owner_dashboard_test.dart` | Pumps `CampOwnerDashboardScreen` directly (sidesteps login-gating, same as `home_test.dart`); with no session renders the demo placeholder business info, with a session set on `AuthService` renders the real campsite/host name and email; checks seeded reservations render, Confirm/Decline flips a pending reservation's status, and Add Reservation appends a new one; seeded message threads render with a last-message preview, opening a thread and replying as owner updates it and the preview. |
   | `discover_test.dart`, `camp_results_test.dart` | Category grid renders; tapping a category filters to matching camps; tapping a result opens Camp Details. |
   | `camp_details_test.dart`, `write_review_test.dart` | Reviews tab renders; writing a review updates the aggregate rating/count live; review-form validation and pro/con chip add; Message Campsite opens a thread and a sent message appears. |
   | `message_thread_test.dart` | Pumps `MessageThreadScreen` directly (sidesteps needing Camp Details/the dashboard, same pattern as `home_test.dart`); as camper renders the seeded conversation, sending a message appends it to the thread. |
   | `other_user_profile_test.dart` | Pumps `OtherUserProfileScreen` directly (same pattern as `home_test.dart`); renders the identity block; requesting to follow flips to Requested then Following after a real (non-simulated) delay; Message opens a thread and a sent message appears. |
   | `schedule_trip_test.dart`, `trip_planner_test.dart`, `trip_details_test.dart` | Missing-dates and overlapping-range conflict validation; a valid range pops a `Trip` and appends it to `sampleTrips`; seeded trips render grouped/sorted on Trip Planner; a full round trip — schedule from Camp Details, confirm the snackbar, see it on a freshly-pumped Trip Planner; canceling a trip from Trip Details removes it from the list; Trip Details' View Camp opens Camp Details for the same camp. |
   | `create_post_test.dart`, `post_details_test.dart` | Caption validation and cancel; like toggle and adding a comment updates the thread. |
   | `profile_test.dart`, `edit_profile_test.dart` | Identity block/tabs render, tab switching, Edit Profile and Trip Planner navigation; form pre-populates and validates. |
   | `communities_test.dart`, `community_feed_test.dart`, `create_community_test.dart` | Your/Suggested sections, join/leave, tap-through to Community Feed, create-community flow; pinned posts, Rules/Members tabs, like toggle, compose; name/description validation and Public/Private toggle. |

   One run of `profile_test.dart` previously hit a transient `AppConnectionException` while waiting for the debug service to connect — a plain retry succeeded, so treat that as flaky rather than a real failure if it recurs.

See [`integration_test/`](integration_test/) and the driver shim at [`test_driver/integration_test.dart`](test_driver/integration_test.dart).

## Deployment

Web builds deploy to Netlify, to a separate `staging` or `production` site, via a **manually-triggered** GitHub Actions workflow — [`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml). Nothing deploys automatically on push.

### One-time setup

1. **Netlify sites:** create two separate Netlify sites — one for staging, one for production (Netlify dashboard → Add new site, or `netlify sites:create` via the CLI). They can start empty; the GitHub Actions workflow pushes builds to them, there's no need to connect them to the repo via Netlify's own Git integration. Note each site's **Site ID** (Site configuration → General → Site details).

2. **Auth token:** generate a Netlify personal access token (User settings → Applications → New access token). The same token can be used for both sites as long as they're on the same Netlify account/team.

3. **GitHub Environments:** in this repo's Settings → Environments, create two environments named exactly `staging` and `production`. Add these secrets to **each** (values differ per environment — that's the point of using separate Supabase projects and separate Netlify sites):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `NETLIFY_AUTH_TOKEN` — the personal access token (can be the same value in both environments)
   - `NETLIFY_SITE_ID` — that environment's Netlify site ID (different per environment)

   Optionally add a required reviewer to the `production` environment for an extra manual approval gate on top of the manual trigger.

### Deploying

1. Go to the repo's **Actions** tab → **Deploy web** workflow → **Run workflow**.
2. Choose `staging` or `production` from the dropdown, then run it.

The job installs Flutter, runs `flutter analyze` and `flutter test` first (deploy is blocked if either fails), builds the web release with that environment's Supabase secrets baked in via `--dart-define`, then runs `netlify deploy --dir=build/web --prod` against that environment's site.

## Project structure

```
lib/main.dart               app entry point, theme + routes
lib/config/env.dart         reads SUPABASE_URL / SUPABASE_ANON_KEY
lib/services/auth_service.dart  Supabase Auth, with a dummy fallback when unconfigured
lib/theme/app_theme.dart    light/dark theme (nature-inspired palette)
lib/widgets/auth_layout.dart shared layout for register/login/forgot-password
lib/screens/                landing, auth, home, discover/camp results/camp details/write review, schedule trip/trip planner/trip details, create post/post details, communities/community feed/create community, profile/edit profile screens
lib/models/                 content types (HomeFeedItem, Camp, Review, Comment, Profile, Trip, Community, CommunityMember, CommunityPost)
lib/data/                   placeholder sample content for every screen above (no matching Supabase schema yet)
test/                       unit/widget tests
integration_test/           Flutter driver end-to-end tests (web)
test_driver/                driver shim for integration_test on web
.maestro/                   Maestro end-to-end flows (Android/iOS)
.github/workflows/          CI: manual staging/production web deploy
netlify.toml                Netlify build/publish config
docs/                       product & UX planning docs
```

## Tech stack

- [Flutter](https://flutter.dev) (web, Android, iOS from one codebase)
- [supabase_flutter](https://pub.dev/packages/supabase_flutter) (Auth)
- [image_picker](https://pub.dev/packages/image_picker) (avatar/cover photo selection on the Edit Profile screen)
- [Maestro](https://maestro.mobile.dev) (end-to-end UI testing, Android/iOS)
- [integration_test](https://pub.dev/packages/integration_test) + chromedriver (end-to-end testing, web)
- [Netlify](https://www.netlify.com) (web deployment, staging + production sites) via [GitHub Actions](.github/workflows/deploy-web.yml) (manual trigger only)
