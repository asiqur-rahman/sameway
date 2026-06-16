# Same Way — Flutter App

Community carpool app for verified office commuters in Bangladesh.

Part of the Same Way monorepo. API lives in `../backend/`, browser admin in `../web/`.

## Run

Edit **`dart_defines.json`** (API URL, map settings), then:

```bash
flutter pub get
flutter run
```

The app loads `dart_defines.json` automatically on startup — **no `--dart-define-from-file` needed**.

After changing the file: **stop the app and run again** (hot reload does not reload config).

```bash
adb connect 192.168.31.68:42933
flutter run -d 192.168.31.68:42933
```

**QA navigation:** Open `/catalog` to jump to any screen.

## Backend API

Start the API from `../backend/` (`npm run dev`). **All environment values live in `dart_defines.json`** — nothing is hardcoded in Dart:

| Key | Example |
|-----|---------|
| `API_BASE_URL` | `http://192.168.31.47:3000/api/v1` (physical device) or `http://10.0.2.2:3000/api/v1` (emulator) |
| `MAP_TILE_URL` | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |
| `DEFAULT_MAP_CENTER` | `23.8103,90.4254` (`lat,lng`) |
| `DEFAULT_HOME` | `23.8759,90.3795` |
| `DEFAULT_OFFICE` | `23.7330,90.4172` |
| `API_ENABLED` | `false` to run UI without backend (optional) |
| `FCM_DEV_TOKEN` | dev push token (optional) |

Copy `dart_defines.example.json` → `dart_defines.json` and set `API_BASE_URL` to your PC’s Network URL from `npm run dev`.

## Project structure

```
lib/
├── core/
│   ├── api/        # Dio client, JWT, repositories
│   ├── session/    # AppSession, AppDataStore
│   └── ...
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── offer_ride/
│   ├── find_ride/
│   ├── match/
│   ├── ride_day/
│   ├── admin/
│   ├── web/
│   └── dev/
└── router/app_router.dart
```

## User flows

```
Splash → Sign Up → Profile → Vehicle → Work Location → Office ID → Home
Home (Offer) → Post Ride → Route → Requests
Home (Find) → Search → Results → Detail → Request → Chat
Bottom nav: Home | Rides | Chat | Profile
```

## Maps (free — OpenStreetMap)

The app uses **flutter_map** with **OpenStreetMap** tiles. No Google Cloud account or API key is required.

- Pin office/home on the map → coordinates saved directly
- Address labels come from the backend **Nominatim** geocoder (also free)
- Works on Android, iOS, and web

Location permissions are declared for “my location” when picking pins.

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

**Live markers:** Route maps animate a driver marker along the polyline. When the backend exposes GPS on `GET /rides/:id/live`, polling can replace the demo animation.

## Next integration

- **Live GPS:** Poll ride live endpoint when driver coordinates are available (Phase 2b)
