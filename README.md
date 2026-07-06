# Camper

Camper is a camping-community app for the Philippines — discover camps, share trips, and connect with other campers. Built with Flutter so the same codebase targets web, Android, and iOS. Product/UX planning docs live in [`docs/`](docs/).

Currently implemented: registration, login, and forgot-password screens (responsive, web + mobile) wired to Supabase Auth, a Home Feed screen (mixed feed, bottom tab bar, per [docs/ux/wireframes.md](docs/ux/wireframes.md)) shown after a successful login, and a Profile screen (own-profile view + a working Edit Profile form) reachable from Home's bottom tab bar.

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
- [`test/register_screen_test.dart`](test/register_screen_test.dart) — required-field errors, invalid email format, mismatched password/confirm password, and a fully valid submit succeeding via the dummy auth fallback
- [`test/login_screen_test.dart`](test/login_screen_test.dart) — required-field errors, invalid email format, valid submit navigating to `/home` via the dummy auth fallback, navigation to `/forgot-password` and `/register`
- [`test/forgot_password_screen_test.dart`](test/forgot_password_screen_test.dart) — empty/invalid email validation, valid submit succeeding via the dummy auth fallback, navigation back to `/login`
- [`test/home_screen_test.dart`](test/home_screen_test.dart) — app bar/bottom tab bar render, mixed feed content renders, "coming soon" messages for unbuilt tabs/search/create-post
- [`test/profile_screen_test.dart`](test/profile_screen_test.dart) — identity block and tab labels render, settings/follower-stat "coming soon" messages, switching tabs shows matching sample content, Edit Profile navigation
- [`test/edit_profile_screen_test.dart`](test/edit_profile_screen_test.dart) — form pre-populates from the passed profile, name validation, style-chip toggling, avatar/cover picker buttons don't crash, Save pops with the edited profile
- [`test/widget_test.dart`](test/widget_test.dart) — landing screen → registration navigation

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

   Home is only reachable after logging in. The flow's default credentials (`dummy@example.com` / `dummy-password`) work as-is against a build without `--dart-define-from-file`, since the dummy auth fallback accepts any credentials. Against a build with real Supabase credentials, override with a pre-existing, **email-confirmed** test account instead: `maestro test -e MAESTRO_TEST_EMAIL=you@example.com -e MAESTRO_TEST_PASSWORD=yourpassword .maestro/home_smoke.yaml`.

   ```bash
   maestro test .maestro/profile_smoke.yaml
   maestro test .maestro/edit_profile_flow.yaml
   ```

   Same login requirement and credential overrides as `home_smoke.yaml` above. `profile_smoke.yaml` logs in, taps into Profile from the bottom nav, and checks a tab switch; `edit_profile_flow.yaml` additionally opens Edit Profile, changes the name field, saves, and confirms the change is reflected back on Profile.

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

3. In another terminal, run a flow. Run these **without** `--dart-define-from-file` so Supabase is intentionally left unconfigured — each test asserts the dummy auth fallback succeeds, the same case the unit tests cover, but through a real browser instead of the widget-test harness:

   ```bash
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/register_test.dart -d chrome
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/login_test.dart -d chrome
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/forgot_password_test.dart -d chrome
   ```

   Each opens an actual Chrome window, navigates from the landing page to the relevant screen, submits an empty form and checks the validation messages, then fills a fully valid form and confirms it succeeds via the dummy auth fallback instead of crashing. All three were run and passed in this environment against a real Chrome window (chromedriver 149.x).

   ```bash
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/home_test.dart -d chrome
   ```

   Pumps `HomeScreen` directly rather than going through a real login (same reasoning as the Maestro `home_smoke.yaml` flow — reaching it via a real sign-in adds an extra step this test doesn't need), and checks the feed renders plus the search/create-post/tab-bar "coming soon" messages. Also run and passed here against a real Chrome window.

   ```bash
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/profile_test.dart -d chrome
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/edit_profile_test.dart -d chrome
   ```

   Same "pump the screen directly" approach as `home_test.dart`. `profile_test.dart` checks the identity block/tabs render, the settings "coming soon" message, tab switching, and Edit Profile navigation; `edit_profile_test.dart` checks the form pre-populates and name validation. Both run and passed here against a real Chrome window (one run of `profile_test.dart` hit a transient `AppConnectionException` while waiting for the debug service to connect — a plain retry succeeded, so treat that as flaky rather than a real failure if it recurs).

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
lib/screens/                landing, registration, login, forgot-password, home, profile, edit-profile screens
lib/models/home_feed_item.dart Home Feed content types
lib/models/profile.dart     Profile content types (UserProfile, experience level, tab items)
lib/data/sample_feed.dart   placeholder Home Feed content (no posts/camps schema yet)
lib/data/sample_profile.dart placeholder Profile content (no profiles schema yet)
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
