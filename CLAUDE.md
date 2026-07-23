# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Camper (CampHub PH) — a camping-community app for the Philippines (Reddit + Instagram + Facebook Groups + AllTrails + Google Maps mashup, community-first; marketplace deliberately deferred). Single Flutter codebase targeting web, Android, and iOS. Product/UX docs live in `docs/` (`PRD.md`, `personas.md`, `information-architecture.md`, `navigation-structure.md`, `features.md`) and `docs/ux/` (`user-journeys.md`, `wireframes.md` — the per-screen spec of record, with "Implemented (Phase 3, ...)" notes appended as screens ship).

There is **no real backend schema yet** beyond Supabase Auth — every content screen (posts, camps, reviews, communities, profiles, notifications, trips, reservations, messages) renders from static sample data in `lib/data/`, typed by matching models in `lib/models/`. Swapping in a real query is future work; don't build around Supabase tables that don't exist.

## Commands

```bash
flutter pub get                                    # install deps
flutter run -d chrome --dart-define-from-file=.env  # run on web (omit the define flag to use the dummy-auth fallback, no Supabase project needed)
flutter run -d <device-id> --dart-define-from-file=.env  # Android/iOS/etc — `flutter devices` to list targets

flutter analyze                                     # static analysis, must stay clean
flutter test                                        # all widget/unit tests
flutter test test/<file>_test.dart                  # a single widget test file

# Web end-to-end (real Chrome via chromedriver) — see README "Web end-to-end tests"
chromedriver --port=4444                            # in its own terminal, matching your installed Chrome's major version
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/<file>.dart -d chrome

# Mobile end-to-end (Maestro, needs a running Android/iOS device or emulator)
maestro test .maestro/<flow>.yaml
maestro test .maestro/                               # every flow
```

`.env` is created from `.env.example` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) and read via `String.fromEnvironment` in `lib/config/env.dart`. Deployment is a manually-triggered GitHub Actions workflow (`.github/workflows/deploy-web.yml`) to Netlify staging/production sites — nothing deploys on push; the job gates on `flutter analyze` + `flutter test`.

## Architecture conventions

**Dummy auth fallback.** All auth calls go through `lib/services/auth_service.dart`, a single `AuthService` wrapping Supabase's `signUp`/`signInWithPassword`/`resetPasswordForEmail`. When `Env.isConfigured` is false (no `--dart-define-from-file`), it fakes success after a short delay instead of touching Supabase — any credentials work, register/forgot-password show "Check your email", login navigates to `/home` (or `/owner-home` for a camp-owner account). Keep new auth-related code routed through `AuthService` rather than reintroducing a hard "not configured" error path.

**Routing: named routes vs. typed pushes.** `lib/main.dart`'s `MaterialApp.routes` table only holds top-level/bottom-nav-reachable screens (`/home`, `/discover`, `/map`, `/communities`, `/profile`, `/trips`, auth screens, etc.). Everything else — detail screens, forms, anything needing constructor args — is pushed via `Navigator.push(MaterialPageRoute(builder: (_) => Screen(arg: value)))`, not a named route. Screens that mutate their argument and need the caller to see the update return it via `Navigator.pop(context, updated)` and the caller merges it back by id (see `camp_results_screen.dart`'s `_openCamp`, `communities_screen.dart`'s `_openCommunity`).

**State: no Provider/Riverpod/Bloc.** Cross-screen state lives directly in the `lib/data/sample_*.dart` lists. Two patterns coexist, chosen per-feature:
- *Shared mutable list, mutated in place* (`sampleTrips`, `sampleOtherUsers`, `sampleNotifications`, `sampleReservations`, `sampleMessageThreads`) — used when independently-pushed screens (e.g. Camp Details and Trip Planner) both need to read/write the same canonical state with no shared ancestor.
- *Copied into local `State`, synced via push/pop return values* (`sampleCommunities`, `sampleCamps` as rendered by list screens) — used when one screen owns the canonical view of a list.

When adding a feature, check how the data it touches is already modeled before picking a pattern — don't introduce a third one.

**No shared tile/card widgets.** Each screen defines its own private result-card/row widgets (e.g. `_CampResultCard` in `camp_results_screen.dart`, `_CommunityCard` in `communities_screen.dart`) rather than importing a common one, even when visually near-identical. Follow this when adding a new list screen instead of extracting a shared component.

**Theme.** `lib/theme/app_theme.dart` defines the brand palette (`AppColors.brand`/`brandDark`/`brandStrong`/`gold`, `surfaceLight`/`surfaceDark`, `borderLight`/`borderDark`) — vivid blue + gold, not the earlier teal/amber "nature" scheme. Screens wrap content in `ConstrainedBox(maxWidth: 640)` centered in a `SafeArea` for readable width on wide/web viewports.

## Testing conventions (enforced project-wide, not optional)

Every screen needs **both**:
1. A widget test (`test/<screen>_test.dart`) — wrap in `MaterialApp(home: Screen())`; bump `tester.view.physicalSize` (e.g. `Size(800, 2400)`) for sliver-heavy content, since `GridView`/`ListView`/`TabBarView` only mount widgets within the viewport even when eagerly provided.
2. A chromedriver-verified `integration_test/<screen>_test.dart` (real Chrome window via `flutter drive`) — this is a hard rule for this repo, not just widget-test coverage.

A `.maestro/*.yaml` flow is also expected per feature for mobile coverage, though these are typically written but **unverified** (no Android/iOS emulator available in most dev environments) — verify locally before trusting one in CI. Any icon-only `IconButton`/FAB needs a `tooltip:` set, both for accessibility and because Maestro can only target elements by visible text or accessibility label.

Known gotchas:
- `flutter drive` can hang for a long time with `AppConnectionException` after many consecutive runs against the same chromedriver — kill stray processes between runs (`taskkill //IM chrome.exe //F`, `//IM dart.exe //F` on Windows) rather than assuming a real failure.
- `Chip.onDeleted` only fires on its delete icon's own hit target, not the whole chip.
- A custom `IconButton` back arrow isn't recognized by `tester.pageBack()` — tap the back button's own key instead.
- Widgets positioned outside a `Stack`'s implicit size (`clipBehavior: Clip.none`) paint but don't hit-test — wrap in a `SizedBox` sized to include the overflow.
