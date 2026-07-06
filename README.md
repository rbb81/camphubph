# Camper

Camper is a camping-community app for the Philippines — discover camps, share trips, and connect with other campers. Built with Flutter so the same codebase targets web, Android, and iOS. Product/UX planning docs live in [`docs/`](docs/).

Currently implemented: the registration screen (responsive, web + mobile), wired to Supabase Auth.

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

5. Once it opens, click **Create your account** to reach the registration screen at `/#/register`.

Values are read via `String.fromEnvironment` in [`lib/config/env.dart`](lib/config/env.dart) — if you forget `--dart-define-from-file`, the app still runs but the registration form will show a "Supabase isn't configured" error instead of silently failing.

## Run on Android / iOS

Same steps, just target a device/simulator instead of Chrome:

```bash
flutter run -d <device-id> --dart-define-from-file=.env
```

Run `flutter devices` to list available targets.

## Debugging registration

- Sign-ups call `Supabase.instance.client.auth.signUp` (see [`lib/screens/register_screen.dart`](lib/screens/register_screen.dart)).
- Supabase's default email-confirmation flow applies: after signing up, check **Authentication → Users** in the Supabase dashboard to see the new (unconfirmed) user, and **Authentication → Logs** if the confirmation email doesn't show up.
- To skip email confirmation while developing, toggle it off under **Authentication → Providers → Email → Confirm email** in the Supabase dashboard.
- Supabase is initialized once in [`lib/main.dart`](lib/main.dart); it's skipped entirely (not crash-on-missing-config) if `.env` values aren't provided, so `flutter run` without `--dart-define-from-file` still boots the UI for layout/debugging.

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

Covers (see [`test/register_screen_test.dart`](test/register_screen_test.dart)):
- required-field validation errors on empty submit
- invalid email format
- mismatched password / confirm password
- a fully valid submit when Supabase isn't configured (asserts the friendly config error instead of a crash)

[`test/widget_test.dart`](test/widget_test.dart) covers the landing screen → registration navigation.

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

   Fills a valid form and submits for real — the device must be running a build with real Supabase credentials (step 1 above with `.env` filled in), since it asserts the "Check your email" success state.

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

3. In another terminal, run the flow. Run it **without** `--dart-define-from-file` so Supabase is intentionally left unconfigured — the test asserts the graceful "Supabase isn't configured" fallback, the same case the unit tests cover, but through a real browser instead of the widget-test harness:

   ```bash
   flutter drive \
     --driver=test_driver/integration_test.dart \
     --target=integration_test/register_test.dart \
     -d chrome
   ```

   This opens an actual Chrome window, taps through from the landing page to `/register`, submits an empty form and checks all four validation messages, then fills a fully valid form and confirms the config-error fallback shows up instead of a crash.

See [`integration_test/register_test.dart`](integration_test/register_test.dart) and the driver shim at [`test_driver/integration_test.dart`](test_driver/integration_test.dart).

## Project structure

```
lib/main.dart               app entry point, theme + routes
lib/config/env.dart         reads SUPABASE_URL / SUPABASE_ANON_KEY
lib/theme/app_theme.dart    light/dark theme (nature-inspired palette)
lib/screens/                landing + registration screens
test/                       unit/widget tests
integration_test/           Flutter driver end-to-end tests (web)
test_driver/                driver shim for integration_test on web
.maestro/                   Maestro end-to-end flows (Android/iOS)
docs/                       product & UX planning docs
```

## Tech stack

- [Flutter](https://flutter.dev) (web, Android, iOS from one codebase)
- [supabase_flutter](https://pub.dev/packages/supabase_flutter) (Auth)
- [Maestro](https://maestro.mobile.dev) (end-to-end UI testing, Android/iOS)
- [integration_test](https://pub.dev/packages/integration_test) + chromedriver (end-to-end testing, web)
