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

### Unit / widget tests

```bash
flutter test
```

Covers (see [`test/register_screen_test.dart`](test/register_screen_test.dart)):
- required-field validation errors on empty submit
- invalid email format
- mismatched password / confirm password
- a fully valid submit when Supabase isn't configured (asserts the friendly config error instead of a crash)

[`test/widget_test.dart`](test/widget_test.dart) covers the landing screen → registration navigation.

### Maestro end-to-end flows

Flows live in [`.maestro/`](.maestro/) and drive a real build on a device/emulator/simulator (`appId: com.camphubph.camper`).

1. Install [Maestro](https://maestro.mobile.dev) and have an Android emulator, iOS simulator, or physical device running with the app installed:

   ```bash
   flutter run -d <device-id> --dart-define-from-file=.env
   ```

2. In another terminal, run a flow:

   ```bash
   maestro test .maestro/register_validation.yaml
   ```

   `register_validation.yaml` only checks client-side validation, no Supabase call is made.

   ```bash
   maestro test .maestro/register_happy_path.yaml
   ```

   `register_happy_path.yaml` fills a valid form and submits — this one requires the running build to actually be configured with real Supabase credentials, since it asserts the "Check your email" success state.

These flows haven't been run against a live emulator in this environment (none was available here) — verify locally before relying on them in CI.

## Project structure

```
lib/main.dart               app entry point, theme + routes
lib/config/env.dart         reads SUPABASE_URL / SUPABASE_ANON_KEY
lib/theme/app_theme.dart    light/dark theme (nature-inspired palette)
lib/screens/                landing + registration screens
test/                       unit/widget tests
.maestro/                   Maestro end-to-end flows
docs/                       product & UX planning docs
```

## Tech stack

- [Flutter](https://flutter.dev) (web, Android, iOS from one codebase)
- [supabase_flutter](https://pub.dev/packages/supabase_flutter) (Auth)
- [Maestro](https://maestro.mobile.dev) (end-to-end UI testing)
