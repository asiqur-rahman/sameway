# SameWay

Community carpool app for verified office commuters in Bangladesh.

## Run

```bash
flutter pub get
flutter run
flutter run -d 192.168.31.68:42805
flutter run -d chrome --web-port=7357
```

**QA navigation:** Open `/catalog` in the app (Screen Catalog) to jump to any screen.

## What's implemented (all Figma phases)

| Phase | Screens | Status |
|-------|---------|--------|
| A — Assets & design system | Colors, typography, status bar, UI kit | Done |
| B — Onboarding (6) | Splash, Sign Up, Profile, Vehicle, Work Location, Office ID | Done |
| C — Ride flows (10) | Post Ride, map pickers, route confirm, requests, search, detail | Done |
| D — Match & chat (6) | Request Sent, Chat list/conversation, Profile, Rides, Routes | Done |
| E — Ride day (6) | Reminders, departure, heading out, pickup, notifications | Done |
| E — Admin (4) | Dashboard, verification, users, config | Done |
| E — Web (7) | Landing, sign-in, dashboard, find, post, rides, profile | Done |

**Total: 39+ screens** wired in `lib/router/app_router.dart`.

## Project structure

```
lib/
├── core/
│   ├── routes/app_routes.dart      # All route constants
│   ├── theme/                      # Figma tokens
│   └── widgets/                    # Shared UI (buttons, map, chat, admin, web)
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── offer_ride/
│   ├── find_ride/
│   ├── match/
│   ├── ride_day/
│   ├── admin/
│   ├── web/
│   └── dev/screen_catalog_screen.dart
└── router/app_router.dart
```

## User flows

```
Splash → Sign Up → Profile Setup → Vehicle → Work Location → Office ID → Home
Home (Offer) → Post Ride → Pick Start/End → Route Confirmed → Post → Requests
Home (Find) → Search → Results → Ride Detail → Request Sent → Chat
Bottom nav: Home | Rides | Chat | Profile
```

## Maps & chat (next integration)

- **Maps:** UI uses `MapPlaceholder`; swap for live `google_maps_flutter` after adding API keys in `android/app/src/main/AndroidManifest.xml` and iOS `AppDelegate`.
- **Chat:** UI shell with mock messages; connect Firebase/WebSocket for real-time.

## Design tokens (from Figma)

| Token | Value |
|-------|-------|
| Primary | `#10B981` |
| Background | `#F8FAFC` |
| Text | `#0F172A` |
| Muted | `#94A3B8` |
