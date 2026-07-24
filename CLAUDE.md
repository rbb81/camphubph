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

**State: no Provider/Riverpod/Bloc.** Cross-screen state lives directly in the `lib/data/sample_*.dart` lists. Three patterns coexist, chosen per-feature:
- *Shared mutable list, mutated in place* (`sampleTrips`, `sampleOtherUsers`, `sampleNotifications`, `sampleReservations`, `sampleMessageThreads`) — used when independently-pushed screens (e.g. Camp Details and Trip Planner) both need to read/write the same canonical state with no shared ancestor.
- *Copied into local `State`, synced via push/pop return values* (`sampleCommunities`, `sampleCamps` as rendered by list screens) — used when one screen owns the canonical view of a list.
- *Shared mutable single object* (`sampleSettings`, a plain mutable `AppSettings` with non-final fields — `lib/data/sample_settings.dart`) — the single-object analog of the shared-mutable-list pattern, for a bag of toggles/prefs that doesn't fit a `List`. Mutated directly (`sampleSettings.pushNotifications = false`), no `copyWith`.

When adding a feature, check how the data it touches is already modeled before picking a pattern — don't introduce a fourth one.

**Modeling a relationship that isn't derivable from existing data.** If a feature needs a relationship the current model can't compute (e.g. "who follows the current user," when the existing model only tracks "does the current user follow them"), add one new field to the existing model with fixed seed values rather than inventing a parallel data structure or fabricating a full reverse graph — see `FollowableUser.followsMe` (`lib/models/followable_user.dart`), seeded on a handful of `sample_other_users.dart` entries for `follow_list_screen.dart`'s Followers list. Don't feel obligated to make the seed data internally consistent with unrelated display-only numbers (e.g. `UserProfile.followerCount` staying a large arbitrary int with no backing identities) — that mismatch is expected and already called out in `docs/ux/wireframes.md`.

**Global reactive state (one exception to "no Provider/Riverpod/Bloc"):** `themeModeNotifier` (`lib/theme/app_theme.dart`), a top-level `ValueNotifier<ThemeMode>`, is the one piece of state that needs to trigger a rebuild of the `MaterialApp` root itself (Settings' Appearance selector) rather than just being read by screens. `CamperApp` wraps its `MaterialApp` in a `ValueListenableBuilder<ThemeMode>` listening to it. Don't reach for this pattern for ordinary cross-screen data — the `sample_*.dart` patterns above cover that; only use a `ValueNotifier` when something outside any screen's widget tree (the app root, a route table) needs to react.

**Carrying a pop result through a screen's default back button.** When a screen needs to hand a value back to its caller (per the push/pop convention above) but should still use `AppBar`'s normal auto-generated back button (not a custom `IconButton`), wrap the `Scaffold` in `PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) { if (didPop) return; Navigator.of(context).pop(theValue); })` — this intercepts every pop path (AppBar back button, system back gesture, `tester.pageBack()`) uniformly. See `community_feed_screen.dart` (pops the updated `Community`) and `settings_screen.dart` (pops an edited `UserProfile?`, or nothing if none). Prefer this over a custom `leading` `IconButton`, which `tester.pageBack()` doesn't recognize (see the gotcha below).

**Destructive actions.** Only Log Out (`settings_screen.dart`) confirms via an `AlertDialog` today — Trip Details' Cancel Trip fires immediately with no confirmation, so don't treat that as the precedent for a new destructive action. Give the dialog's confirm button text distinct from the triggering row/button's label (e.g. row "Log Out" vs. dialog "Yes, Log Out") so `find.text`/Maestro's `tapOn` can't ambiguously match both.

**No shared tile/card widgets.** Each screen defines its own private result-card/row widgets (e.g. `_CampResultCard` in `camp_results_screen.dart`, `_CommunityCard` in `communities_screen.dart`) rather than importing a common one, even when visually near-identical. Follow this when adding a new list screen instead of extracting a shared component.

**`lib/widgets/` is for cross-cutting *logic-bearing* helpers, not an exception to the rule above.** `auth_layout.dart` (`AuthScaffold`/`BrandPanel`/`FormErrorBanner`/`InfoPanel`/`fieldLabel`, shared across 8 auth screens) and `hashtag_mention_text.dart` (`HashtagMentionText`, a regex-parsing tappable-text widget shared across Home Feed/Post Details/Community Feed/Community Post Details) are both here because duplicating them would duplicate real *logic* (form layout, token parsing + tap routing) — categorically different from duplicating a per-screen *visual* card/row, which is what "no shared tile/card widgets" actually targets. When deciding whether something belongs in `lib/widgets/`, ask whether skipping it would mean copy-pasting non-trivial logic (share it) or just a similar-looking layout (don't).

**One screen, mode enum — not two near-identical files.** When a feature is really the same screen shown two ways (differing only in a filter predicate and a title), use one `StatefulWidget` taking an enum param rather than duplicating the whole file — see `FollowListScreen({required FollowListType type})` (`lib/screens/follow_list_screen.dart`, `FollowListType.followers`/`.following`). This doesn't conflict with the no-shared-tile-widget rule above — that rule is about not sharing row widgets *across different screens/features*; splitting one cohesive feature into two files just to avoid an enum would be the actual duplication.

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
- Bumping `tester.view.physicalSize` only helps **widget tests** render below-the-fold lazy-list content — a chromedriver `integration_test` runs in an actual Chrome window, so `tester.view.physicalSize` doesn't apply there. If a `ListView`/`GridView` is taller than the real browser window, a below-the-fold item may not even be built (not just off-screen), so `find.text`/`find.byKey` returns 0 widgets. Fix with `tester.scrollUntilVisible(finder, someDelta, scrollable: find.byType(Scrollable))` before interacting with it (see `integration_test/settings_test.dart`, `home_screen_test.dart`), not a bigger `physicalSize`.
- Maestro's plain-text `tapOn` also collides when a **list has several rows with an identical button label at the same time** (not just the already-documented Accept/Accepted-style status-text collision) — e.g. `follow_list_flow.yaml`'s multiple "Follow Back" buttons, one per not-yet-followed row. Disambiguate with `tapOn: {text: "...", index: N}` (same mechanism `login_validation.yaml` already uses for the second "Log in"), picking the index from the underlying sample data's fixed order.
- `Text.rich`/`RichText` with a `TapGestureRecognizer` per tagged span (`HashtagMentionText`) can't be reliably tapped by geometry in widget/integration tests — find the `RichText`, walk its `TextSpan` tree for the target span, and call `(span.recognizer! as TapGestureRecognizer).onTap!()` directly (see `test/hashtag_mention_text_test.dart`). Same "sidestep geometry" fallback already used for `InkWell`/`GestureDetector` elsewhere in this repo (Profile's overlapping avatar, `flutter_map` markers). Note `find.text()` *does* match plain (untagged) `Text.rich` content here since `Text.rich` is still a `Text` widget under the hood — this gotcha is specifically about tapping one sub-span, not about finding text.
