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

## Google Maps (free mobile SDK)

The app uses **Google Maps Mobile SDK** on Android/iOS via `google_maps_flutter`. The mobile SDK has **no per-map-load charge** (unlike the JavaScript API). You only need a free Google Cloud API key with billing optional for low usage.

### 1. Create an API key

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**
3. Create an API key and restrict it to your app package/bundle ID

### 2. Android

Add to `android/local.properties`:

```properties
GOOGLE_MAPS_API_KEY=your_key_here
```

Location permissions are declared in `AndroidManifest.xml`; the app requests permission when showing “my location”.

### 3. iOS

Set your key in `ios/Runner/Info.plist`:

```xml
<key>GMSApiKey</key>
<string>your_key_here</string>
```

### 4. Run

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

**Live markers:** Route maps animate a driver marker along the polyline. When the backend exposes GPS on `GET /rides/:id/live`, polling can replace the demo animation.

Without a key (or on web/desktop), maps fall back to the painted `MapPlaceholder`.

## Next integration

- **Chat:** Connect to backend chat endpoints or WebSocket
- **Live GPS:** Poll ride live endpoint when driver coordinates are available
