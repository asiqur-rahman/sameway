# Same Way — Flutter App

Community carpool app for verified office commuters in Bangladesh.

Part of the Same Way monorepo. API lives in `../backend/`, browser admin in `../web/`.

## Run

```bash
flutter pub get
flutter run
adb connect 192.168.31.68:42933
flutter run -d 192.168.31.68:42933
flutter run -d chrome --web-port=7357
```

**QA navigation:** Open `/catalog` to jump to any screen.

## Backend API

Start the API from `../backend/` (`npm run dev`). The app connects automatically:

| Platform | Default base URL |
|----------|------------------|
| Android emulator | `http://10.0.2.2:3000/api/v1` |
| iOS sim / web | `http://localhost:3000/api/v1` |
| Physical device | `--dart-define=API_BASE_URL=http://<LAN-IP>:3000/api/v1` |

```bash
# Physical device example
flutter run -d <device> --dart-define=API_BASE_URL=http://192.168.1.10:3000/api/v1
```

Disable API (offline UI only): `--dart-define=API_ENABLED=false`

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

## Next integration

- **API:** Point client to `http://<host>:3000/api/v1`
- **Maps:** Replace `MapPlaceholder` with `google_maps_flutter`
- **Chat:** Connect to backend chat endpoints or WebSocket
