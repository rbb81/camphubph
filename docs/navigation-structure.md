# Navigation Structure

Platform: Flutter mobile app (iOS + Android). Navigation follows familiar Instagram/Facebook-style conventions: a persistent bottom tab bar for the core pillars, with search/notifications/messages reachable from a top bar, and modal/full-screen pushes for everything else.

## 1. Auth / Onboarding Stack (pre-login)

```
Splash Screen
  -> Onboarding (carousel, skippable)
      -> Login
          -> Forgot Password
          -> (success) -> Home Feed
      -> Registration
          -> (success) -> Home Feed
```

- Splash is a transient loading screen (checks session token, routes to Onboarding or straight to Home if already logged in).
- Onboarding is shown once (or until dismissed) for new installs.
- Forgot Password is reached only from Login, and returns to Login on completion.

## 2. Bottom Tab Bar (post-login, persistent)

```
[ Home ]  [ Discover ]  [ Map ]  [ Communities ]  [ Profile ]
```

- **Home** — mixed feed (default landing tab after login)
- **Discover** — category browse grid
- **Map** — interactive map (center tab, primary discovery tool alongside Discover)
- **Communities** — list of joined/suggested communities
- **Profile** — own profile

Each tab maintains its own navigation stack (standard bottom-nav pattern), so switching tabs and back preserves scroll/state per tab.

## 3. Top Bar (contextual, available from Home/Discover/Map/Communities)

```
[ Search ]                          [ Notifications ]  [ Messages ]
```

- **Search** opens the global Search screen (full-screen, not a tab, since it's used situationally, not continuously).
- **Notifications** and **Messages** are icon buttons with unread badges, pushing full-screen stacks.

## 4. Screen-by-screen navigation map

```
Home Feed
 ├─> Post Details            (tap a post)
 │     ├─> Profile (of post author)
 │     ├─> Camp Details       (if post references a camp)
 │     └─> Comments / Report / Share sheet
 ├─> Create Post              (floating action button)
 ├─> Camp Details             (tap a recommended/nearby camp card)
 ├─> Profile (of suggested user)
 └─> Community Feed           (tap a community post's source)

Discover
 └─> Category results (filtered camp list)
       └─> Camp Details
             ├─> Photo Gallery
             ├─> Reviews (list) -> Write/Edit Review
             ├─> Map (centered on this camp)
             └─> Save / Add to Wishlist / Add to Trip

Map
 ├─> Filter sheet (category toggles: camps, mountains, beaches, lakes, trails, waterfalls, attractions)
 └─> Pin tap -> Camp preview card -> Camp Details

Communities (tab)
 ├─> Community Feed
 │     ├─> Rules
 │     ├─> Pinned Posts (surfaced at top of feed)
 │     ├─> Members
 │     ├─> Moderators (mod-only actions if user is a mod)
 │     ├─> Search (within community)
 │     └─> Post Details
 └─> Discover/search other communities -> Community Feed (not yet joined, preview mode)

Search (global, from top bar)
 └─> Tabbed/sectioned results: Camps | Communities | Users | Locations | Activities
       ├─> Camp Details
       ├─> Community Feed
       ├─> Profile (of user result)
       └─> Discover results filtered by province/city/activity

Create Post (modal, full-screen)
 ├─> Photo/multi-image picker
 ├─> Tag location (Camp) picker
 ├─> Tag community (post to a specific community, optional)
 └─> Publish -> returns to originating feed (Home or Community Feed)

Notifications
 └─> Tap notification -> Post Details / Profile / Community Feed / Trip Detail (context-dependent)

Messages
 ├─> Inbox (thread list)
 └─> Thread -> Profile (of other participant)

Profile (own, from tab bar)
 ├─> Settings
 ├─> Saved Camps        -> Camp Details
 ├─> Wishlist           -> Camp Details / Add to Trip
 ├─> Completed Trips    -> Trip Detail (read-only/completed state)
 ├─> Reviews (written)  -> edit/delete
 ├─> Photos             -> Photo Gallery
 ├─> Posts              -> Post Details
 └─> Trip Planner       -> Trip list -> Trip Detail
       └─> Trip Detail
             ├─> Add/edit destinations (Camp picker)
             ├─> Set dates
             ├─> Invite friends (User picker)
             ├─> Checklist
             └─> Status change (Planning -> Confirmed -> Completed)

Profile (other user's, reached via posts/search/followers)
 ├─> Follow / Unfollow
 ├─> Message
 ├─> Posts / Photos / Reviews (read-only view of their public content)
 └─> Followers / Following list
```

## 5. Modal vs. Push conventions

- **Full-screen push (with back navigation):** Camp Details, Post Details, Community Feed, Profile, Search, Notifications, Messages, Settings, Trip Planner/Trip Detail, Saved Camps, Wishlist, Completed Trips, Reviews, Photo Gallery.
- **Modal (dismissible overlay, not part of back stack history):** Create Post, Filter sheets (Map/Discover), Report sheet, Share sheet, Comment composer.
- **Bottom sheets:** quick actions (Save/Wishlist/Add to Trip from a Camp card), category filters on Map/Discover.

## 6. Deep-linking considerations

Shareable/deep-linkable destinations (for share sheets, push notifications, and external links):
- Post Details (`/post/:id`)
- Camp Details (`/camp/:id`)
- Community Feed (`/community/:id`)
- Profile (`/user/:id`)
- Trip Detail, when shared with invited friends (`/trip/:id`, permission-gated to invited users)

Deep links should route through the auth stack first if the user isn't logged in (land on the target screen immediately after login/registration).
