# Same Way

Monorepo for **Same Way** — verified office carpool for commuters in Bangladesh.

```
Project_Sameway/
├── app/       # Flutter mobile & web UI (39+ screens)
├── backend/   # Next.js API (Node.js + PostgreSQL)
└── web/       # React admin dashboard
```

## Quick start

### 1. Flutter app (`app/`)

```bash
cd app
flutter pub get
flutter run
# Physical device (backend on same Wi‑Fi — matches npm run dev Network URL):
flutter run --dart-define-from-file=dart_defines.json
# Android emulator instead:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
# Flutter web UI (user-facing):
flutter run -d chrome --web-port=7357
```

**QA:** Open `/catalog` in the app to jump to any screen.

### 2. API backend (`backend/`)

**Docker (Postgres + Redis + API):**

```bash
cd backend
cp .env.example .env
docker compose up --build -d
# Health: http://localhost:3000/api/v1/health
```

**Or local Node (same `.env`):**

```bash
cd backend
cp .env.example .env    # set DATABASE_URL + JWT secrets
npm install
npm run db:push
npm run db:seed
npm run dev             # http://localhost:3000
```

**Seed admin:** `admin@sameway.local` / `Admin@12345`

### 3. Admin web (`web/`)

```bash
cd web
npm install
npm run dev             # http://localhost:5173
```

Sign in with the admin account above. Vite proxies `/api` to the backend.

## What's in each folder

| Folder | Stack | Purpose |
|--------|-------|---------|
| `app/` | Flutter | User mobile app + in-app admin UI prototypes |
| `backend/` | Next.js, Prisma, PostgreSQL | REST API for auth, rides, chat, admin |
| `web/` | React, Vite, TypeScript | Browser admin: dashboard, verification, users, config |

## Flutter app (`app/`)

| Phase | Screens | Status |
|-------|---------|--------|
| Onboarding (6) | Splash, Sign Up, Profile, Vehicle, Work Location, Office ID | Done |
| Ride flows (10) | Post, map pickers, search, detail, requests | Done |
| Match & chat (6) | Request sent, chat, profile, rides, routes | Done |
| Ride day (6) | Reminders, departure, pickup, notifications | Done |
| Admin (4) | Dashboard, verification, users, config | Done (UI) |
| Web user (7) | Landing, sign-in, dashboard, find, post, rides | Done (UI) |

See `app/README.md` for Flutter structure and flows.

## Production scale (1000+ users)

Designed for real commute-hour load, not demo-only:

- **Search:** DB geo pre-filter, 300 candidate cap, 30s result cache per corridor
- **Geocode:** OpenStreetMap Nominatim by default (free) + 24h server cache
- **Redis:** Set `REDIS_URL` in `backend/.env` when running multiple API instances (optional for dev)
- **User coords:** Stored in `Place` table (HOME/OFFICE) — one row per user per label

See `backend/ARCHITECTURE.md` and `backend/.env.example` for tuning.

## Zero-cost local dev (no paid APIs)

Everything below runs without Google Cloud billing or map API keys:

| Service | Default | Cost |
|---------|---------|------|
| Map tiles | OpenStreetMap via `flutter_map` | Free |
| Geocoding | Nominatim (`GEO_PROVIDER=nominatim`) | Free |
| Database | PostgreSQL local | Free |
| File uploads | Local disk (`./uploads`) | Free |
| Push (FCM) | Optional — outbox logs without Firebase creds | Free until you configure |
| Redis | In-memory fallback when `REDIS_URL` unset | Free |

**Recommended workflow:** pin office/home on the map (coords from pin, not typed address). Optional home text field uses server geocoding when needed.

To switch to Google later: set `GEO_PROVIDER=google` and `GOOGLE_MAPS_API_KEY` in backend `.env`.

## Integration status

- **Work verification (3 steps):** work email → office on map (required) → employee ID
- **Flutter ↔ API:** Wired — JWT auth, ride search/post, bookings, chat, onboarding sync
- **Backend:** Clean architecture, rate-limited geo search, notification outbox worker — see `backend/ARCHITECTURE.md`
- **Admin web ↔ API:** Connected to `/api/v1/admin/*`
- **Maps / chat:** REST + polling; push via `npm run outbox:process`

## Design tokens

| Token | Value |
|-------|-------|
| Primary | `#10B981` |
| Background | `#F8FAFC` |
| Text | `#0F172A` |
| Muted | `#94A3B8` |
