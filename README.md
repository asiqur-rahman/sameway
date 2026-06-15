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
# Physical device:
flutter run -d 192.168.31.68:42933
# Flutter web UI (user-facing):
flutter run -d chrome --web-port=7357
```

**QA:** Open `/catalog` in the app to jump to any screen.

### 2. API backend (`backend/`)

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

## Integration status

- **Work verification (3 steps):** work email → office on map (required) → employee ID
- **Flutter ↔ API:** UI + local session complete; wire `dio`/`http` to `backend/` next
- **Backend:** Rate-limited, geo-optimized search, pooled PostgreSQL, open signup aligned with Flutter
- **Admin web ↔ API:** Connected to `/api/v1/admin/*`
- **Maps / chat:** Placeholders in Flutter; backend has REST + stubs for real-time

## Design tokens

| Token | Value |
|-------|-------|
| Primary | `#10B981` |
| Background | `#F8FAFC` |
| Text | `#0F172A` |
| Muted | `#94A3B8` |
