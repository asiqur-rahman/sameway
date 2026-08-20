# Same Way

### The Intelligent Network for Verified Office Carpooling

> **Same** — because commuting shouldn't be solitary; the same route, the same time, the same direction
> **Way** — the path, the method, the intelligent system that matches verified commuters and turns empty seats into shared journeys

**Same Way** is a self-hosted, production-grade carpool platform for verified office commuters in Bangladesh — combining a Flutter mobile app, a Next.js API backend with Prisma/PostgreSQL, OSRM-powered route matching, and a React admin dashboard into a single intelligent platform that transforms daily commutes.

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Next.js](https://img.shields.io/badge/Next.js-16.2+-000000?logo=nextdotjs&logoColor=white)](https://nextjs.org)
[![React](https://img.shields.io/badge/React-19.2+-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?logo=typescript&logoColor=white)](https://typescriptlang.org)
[![Prisma](https://img.shields.io/badge/Prisma-7.8+-2D3748?logo=prisma&logoColor=white)](https://prisma.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7+-DC382D?logo=redis&logoColor=white)](https://redis.io)
[![OSRM](https://img.shields.io/badge/OSRM-Backend-DC322C?logo=openstreetmap&logoColor=white)](https://project-osrm.org)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://docker.com)
[![License](https://img.shields.io/badge/License-Private-orange)]()
[![Author](https://img.shields.io/badge/Author-Md.%20Asiqur%20Rahman%20Khan-blue)]()

---

## 💡 What is Same Way?

Every office commute in Bangladesh has a question it must answer for every empty seat:

> ***"Is there a verified colleague traveling my route at my time — and can we share the ride safely?"***

**Same Way** is the system that answers that question, at scale, in real time, without a commercial fleet.

It sits as an intelligent layer between commuters and their daily routes. When a user opens the app, Same Way verifies their office identity, learns their home and office locations, matches them with drivers on the same corridor using OSRM-powered routing, and carries them through the entire ride lifecycle — request, chat, live tracking, post-ride review — inside a trusted, verified community.

```
A commuter opens the app
↓
Same Way asks: Are you verified? Where is home? Where is office?
↓
OSRM corridor matching finds drivers on your route with seats
↓
Rider requests → Driver accepts → Chat opens → Live tracking starts
↓
Ride completes → Both rate each other → Trust builds
```

### What makes Same Way different from just a ride-sharing app?

| Generic Ride-Share | Same Way |
| --- | --- |
| Open to anyone | **Verified office commuters** — email domain + employee ID verification |
| Random matches | **Corridor-based matching** — OSRM routing with bbox pre-filter + match scoring |
| No identity trust | **Multi-layer verification** — work email, employee ID, admin approval, office location |
| Consumer-grade | **Enterprise-ready** — admin dashboard, audit log, maintenance mode, domain allowlist |
| Black-box algorithms | **Transparent scoring** — gender preference, min match score, corridor overlap |
| Cloud-dependent | **Self-hosted** — runs on your infra, your data, your control |
| Single platform | **Multi-platform** — Flutter mobile/web + React admin + Next.js API in one monorepo |

### Who is Same Way for?

- **Companies** in Bangladesh reducing parking pressure, fuel costs, and carbon footprint
- **Office parks & business districts** (Gulshan, Banani, Motijheel, Uttara) with dense commuter populations
- **HR & Admin teams** needing a turnkey carpool program with verification and reporting
- **Developers** who want to understand or extend a production-grade, multi-platform carpool stack

### The name

**Same Way** = *Same* (the shared route — the realization that hundreds of colleagues travel the same corridor daily) + *Way* (the intelligent path — the system that discovers, matches, and guides those shared journeys).

Every commuter who joins Same Way doesn't just find a ride — they become part of a **verified mobility network**, where trust is earned, routes are optimized, and empty seats become connections.

---

## Overview

**Use Same Way when you need to:**

- 🚗 **Match verified commuters** on shared routes with OSRM-powered corridor scoring
- ✅ **Verify office identity** via company email domains + employee ID upload + admin approval
- 🗺️ **Optimize routes** with bounding-box pre-filter, candidate capping, and rush-hour caching
- 💬 **Enable ride-day communication** — in-app chat, live status, driver heading-out broadcasts
- ⭐ **Build trust** through post-ride reviews and rating aggregation
- 🛡️ **Administer centrally** — dashboard for users, verifications, domains, maintenance mode
- 📱 **Run everywhere** — Android, iOS, Web (Flutter) + Browser admin (React) + API (Next.js)
- 🏗️ **Deploy on your infra** — Docker Compose with PostgreSQL, Redis, OSRM, zero cloud dependency

---

## ✨ Features

### 🔐 Authentication & Verification

| Feature | Details |
| --- | --- |
| **JWT access + refresh tokens** | Secure rotating session management |
| **Open signup + domain allowlist** | Anyone can sign up; company domains auto-grant the office-verified badge |
| **Employee ID verification** | Upload ID card → admin review → verified (self-verify option available) |
| **Profile completion** | Phone, vehicle, home/office, commute type (drive / ride / both / walk) |
| **Gender preference** | Optional rider/driver filter for cultural comfort |
| **Role-based access** | `USER` (commuter) vs `ADMIN` (dashboard) — enforced at API + UI |
| **Maintenance mode** | One-click toggle blocks signup + ride posting globally |

### 🚗 Ride lifecycle & matching

| Feature | Details |
| --- | --- |
| **Post a ride (drivers)** | Route (OSRM polyline), departure, seats, repeat (once/daily/weekdays), gender |
| **Find rides (riders)** | Corridor search — bbox DB pre-filter → capped candidates → in-memory scoring → pagination |
| **Match scoring** | Corridor overlap % + time proximity + gender preference + min match threshold |
| **Ride request flow** | Pending → Accepted (chat unlocks) / Declined / Cancelled |
| **Ride-day live status** | Driver: Heading out → At pickup → On way → Late / Cancelled · Rider: Confirmed → Boarded |
| **Driver broadcast** | One-tap "Heading out" notification to all confirmed riders |
| **Regular-route templates** | Save home ↔ office once, one-tap post for recurring schedules |
| **Post-ride reviews** | 5-star rating + comment → aggregated driver/rider rating |

### 🗺️ Maps & routing — free, no Google Cloud

| Feature | Details |
| --- | --- |
| **OpenStreetMap tiles** | `flutter_map` + OSM — no API keys |
| **Self-hosted OSRM** | Bangladesh extract (~15 min first boot), MLD algorithm, nearest/route/table |
| **Nominatim geocoding** | Free address search for pin placement |
| **Live route animation** | Animated driver marker; ready for real GPS polling (Phase 2b) |
| **Pin-based places** | Tap map to set home/office → reverse-geocoded labels |

### 💬 Communication & notifications

| Feature | Details |
| --- | --- |
| **In-app chat** | One conversation per ride request — messages, read receipts, timestamps |
| **FCM push** | Ride confirmed, request received, driver ETA, rate ride, verification updates |
| **Outbox pattern** | Reliable delivery via DB outbox table + background worker (30s poll) |
| **Notification feed** | In-app center + mark-read / mark-all-read |

### 🛡️ Admin dashboard (React + Vite)

| Feature | Details |
| --- | --- |
| **Dashboard stats** | Users, verified %, active rides, pending reviews, activity log |
| **User management** | List, search, role toggle, vehicles/places/rides drill-down |
| **Verification queue** | Pending employee IDs → approve / reject with reason |
| **Domain allowlist** | Manage company email domains for auto-verification |
| **System config** | Maintenance mode, auto-verify, global settings |
| **Activity log** | Audit trail of admin actions with actor + timestamp |

### 🏗 Infrastructure & DevOps

| Feature | Details |
| --- | --- |
| **Docker Compose stack** | PostgreSQL 16 + Redis 7 + Next.js API + OSRM + outbox worker + db-setup |
| **Prisma ORM** | Type-safe queries, migrations, seed, Prisma Studio |
| **Rate limiting** | IP + user tiers (signup 8/min, auth 15/min, search 45/min, chat 60/min) |
| **Search cache** | Short TTL (30s) for identical rush-hour searches |
| **File uploads** | Profile photos + employee ID → local volume (S3/R2 ready) |
| **Health endpoint** | `/api/v1/health` for orchestration |
| **PWA support** | Installable Flutter web app for mobile admin access |

---

## 🏗 Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Client Layer                                    │
│  Flutter Mobile (Android/iOS) · Flutter Web (PWA) · React Admin (Vite) │
└───────────────────────────────┬────────────────────────────────────────┘
                                │ HTTPS / REST / JWT
                                ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        API Layer (Next.js 16)                          │
│   /api/v1/* REST · JWT guard · rate limits · Zod validation           │
│   Modules: auth, users, rides, matching, chat, notifications,        │
│            bookings, admin, uploads, reviews                          │
└───────────────┬───────────────────────────────┬────────────────────────┘
                │                               │
┌───────────────▼─────────────┐   ┌─────────────▼──────────────────────┐
│  Infrastructure              │   │  External Services                  │
│  Prisma repos · Redis cache  │   │  PostgreSQL 16 · Redis 7 · OSRM     │
│  OSRM client · FCM · outbox  │   │  (Bangladesh OSM) · Nominatim       │
└─────────────────────────────┘   └──────────────────────────────────────┘
```

### Key design decisions

**Layered architecture** — Routes → Modules → Infrastructure → Prisma/Redis/OSRM. Thin controllers, fat services, pure domain logic.

**Corridor matching** — Not radius search. OSRM computes the route polyline → bbox pre-filter in Postgres → candidate cap (300) → in-memory corridor-overlap scoring → pagination.

**Verification-first** — No ride posting without verified status. Multi-layer: email domain → employee ID → admin approval → office location.

**Self-hosted routing** — OSRM runs locally with a Bangladesh OSM extract. No Google Maps API costs, no external dependency, full data sovereignty.

**Outbox pattern** — Notifications written to a DB outbox → worker polls every 30s → FCM delivery → status update. At-least-once delivery.

**Monorepo** — Backend Prisma models inform frontend types. `dart_defines.json` injects all env config into Flutter — zero hardcoded values.

---

## 🚀 Quick Start

### Prerequisites

| Requirement | Version |
| --- | --- |
| Docker + Docker Compose | v2.20+ |
| Node.js | 20+ |
| Flutter SDK | 3.11+ |
| Android Studio / Xcode | Mobile builds |
| PostgreSQL 14+ | Local-only runs |

### 1 — Backend API (`backend/`)

**Docker (recommended — full stack: Postgres + Redis + OSRM + API + outbox worker):**

```bash
cd backend
cp .env.example .env   # set strong JWT_ACCESS_SECRET / JWT_REFRESH_SECRET
docker compose up --build -d
# API: http://localhost:3000/api/v1/health
```

**Local Node (no Docker):**

```bash
cd backend
cp .env.example .env
npm install
npm run db:push        # create tables
npm run db:seed        # seed demo admin + user + domains
npm run dev            # http://localhost:3000
```

**Seed accounts:**

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@sameway.local` | `Admin@12345` |
| Demo user | `demo@sameway.local` | `Demo@12345` |

> First Docker boot downloads the Bangladesh OSM extract (~15 min); later starts are instant.

### 2 — Admin dashboard (`web/`)

```bash
cd web
npm install
npm run dev      # http://localhost:5173
```

Vite proxies `/api` to `http://localhost:3000`. Login with the seed admin credentials.

### 3 — Flutter app (`app/`)

```bash
cd app
cp dart_defines.example.json dart_defines.json
# Edit dart_defines.json — set API_BASE_URL:
#   physical device  : "http://<YOUR-LAN-IP>:3000/api/v1"
#   Android emulator : "http://10.0.2.2:3000/api/v1"
#   Flutter web      : "http://localhost:3000/api/v1"
flutter pub get
flutter run
```

**QA navigation:** open `/catalog` to jump to any of the 39+ screens.

**Flutter web (user-facing):**

```bash
flutter run -d chrome --web-port=7357
```

> Config lives entirely in `dart_defines.json` — nothing is hardcoded in Dart. After editing, stop and re-run (hot reload ignores config).

---

## 🗂 Repository Layout

```
sameway/
├── app/                    # Flutter mobile & web UI (39+ screens)
│   ├── lib/
│   │   ├── core/           # API client, session, models, maps, theme, config
│   │   ├── features/       # onboarding, home, offer_ride, find_ride, match, ride_day, chat, admin, web, dev
│   │   └── router/         # go_router setup
│   ├── dart_defines.json   # Runtime config (API URL, map tiles, FCM)
│   └── pubspec.yaml
├── backend/                # Next.js API (Node.js + PostgreSQL + Prisma)
│   ├── prisma/
│   │   ├── schema.prisma   # Full domain model (users, rides, chat, admin…)
│   │   └── seed.ts
│   ├── src/
│   │   ├── app/api/v1/     # Thin route handlers (REST)
│   │   ├── modules/        # Service facades per domain
│   │   ├── application/    # Use-cases, DTO mappers, DI container
│   │   ├── domain/         # Repository + port interfaces
│   │   ├── infrastructure/ # Prisma repos, cache, outbox, rate limit, push, geocoding
│   │   └── lib/            # Auth, DB, HTTP, env, validation
│   ├── docker/             # Dockerfile, entrypoint, OSRM setup
│   ├── docker-compose.yml  # pg, redis, api, osrm, outbox, db-setup
│   └── package.json
├── web/                    # React admin dashboard (Vite)
│   ├── src/
│   │   ├── pages/          # Dashboard, Users, Verification, Config, Login
│   │   ├── components/     # AdminLayout, DataTable, StatCard
│   │   ├── auth/           # AuthContext
│   │   └── api/            # client.ts
│   └── package.json
└── README.md
```

---

## ⚙ Configuration

All backend config lives in `backend/.env`. Flutter config lives in `app/dart_defines.json`; runtime-only settings are managed in Admin → Config with no restart.

### Required secrets

```
JWT_ACCESS_SECRET=       # min 32 chars — signs access tokens
JWT_REFRESH_SECRET=      # min 32 chars — signs refresh tokens
DATABASE_URL=postgresql://user:pass@localhost:5432/sameway?schema=public
REDIS_URL=redis://localhost:6379
FIREBASE_PROJECT_ID       # FCM push (optional)
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
OSRM_URL=http://osrm:5000
UPLOAD_DIR=./uploads
CORS_ORIGINS=http://localhost:7357,http://localhost:5173
RATE_LIMIT_ENABLED=true
SEARCH_CANDIDATE_CAP=300
SEARCH_CACHE_TTL_SEC=30
SEARCH_BBOX_BUFFER_KM=18
```

### Runtime-only settings (Admin → Config)

| Setting | Description |
| --- | --- |
| Maintenance mode | Blocks signup + ride posting |
| Auto-verify | Domains auto-verified on signup |
| Domain allowlist | Company email domains |
| Verification method | `ADMIN_ONLY` or `SELF_VERIFY` |
| ID visibility | `ADMIN_ONLY` or `PUBLIC_TO_RIDERS` |

### Flutter config (`app/dart_defines.json`)

| Key | Example |
| --- | --- |
| `API_BASE_URL` | `http://192.168.31.47:3000/api/v1` (device) |
| `MAP_TILE_URL` | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |
| `DEFAULT_MAP_CENTER` | `23.8103,90.4254` |
| `DEFAULT_HOME` | `23.8759,90.3795` |
| `DEFAULT_OFFICE` | `23.7330,90.4172` |
| `API_ENABLED` | `false` to run UI without backend |
| `FCM_DEV_TOKEN` | dev push token (optional) |

---

## 📡 API Reference

Base URL: `http://localhost:3000/api/v1` — all authenticated endpoints use `Authorization: Bearer <accessToken>`.

### Auth & onboarding

| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/auth/signup` | Register (any email; company domains auto-verify) |
| `POST` | `/auth/signin` | Login → access + refresh tokens |
| `POST` | `/auth/refresh` | Rotate tokens |
| `DELETE` | `/auth/refresh` | Logout (invalidate refresh) |
| `GET` | `/auth/me` | Current user + vehicles + places |

### User profile

| Method | Endpoint | Description |
| --- | --- | --- |
| `PATCH` | `/users/me` | Update profile, commute type |
| `POST` | `/users/me/vehicles` | Add vehicle |
| `PATCH` | `/users/me/vehicles/:id` | Update vehicle |
| `POST` | `/users/me/locations` | Upsert home/office |
| `POST` | `/users/me/verification` | Submit employee ID |
| `PATCH` | `/users/me/reminder-settings` | Notification toggles |
| `POST` | `/users/me/device-tokens` | Register FCM token |
| `GET` | `/users/:id/reviews` | Public reviews |

### Rides (offer & find)

| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/rides` | Post a ride (verified users) |
| `GET` | `/rides` | My rides as driver |
| `POST` | `/rides/search` | Find rides (geo prefilter, scoring, cache) |
| `GET` | `/rides/:id` | Ride detail |
| `POST` | `/rides/:id/request` | Rider requests seat |
| `GET` | `/rides/:id/requests` | Driver: incoming requests |
| `POST` | `/rides/:id/requests/:requestId` | Accept request |
| `DELETE` | `/rides/:id/requests/:requestId` | Decline request |
| `POST` | `/rides/:id/heading-out` | Driver broadcast |
| `GET` | `/rides/:id/live` | Live participant statuses |
| `PATCH` | `/rides/:id/participants/:userId/status` | Rider status updates |
| `POST` | `/rides/:id/reviews` | Rate after ride |

### Regular routes & bookings

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET/POST` | `/regular-routes` | Saved route templates |
| `POST` | `/regular-routes/:id/post-ride?departureAt=ISO` | Quick post from template |
| `GET` | `/bookings/mine?status=upcoming|completed` | My rides as rider/driver |

### Chat & notifications

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/chat/conversations` | Conversation list |
| `GET/POST` | `/chat/conversations/:id/messages` | Messages / send |
| `PATCH` | `/chat/conversations/:id/messages` | Mark read |
| `GET` | `/notifications` | Notification feed |
| `PATCH` | `/notifications` | Mark all read |
| `PATCH` | `/notifications/:id/read` | Mark one read |

### Admin

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/admin/dashboard` | Stats |
| `GET` | `/admin/activity` | Activity log |
| `GET/PATCH` | `/admin/users`, `/admin/users/:id` | User management |
| `GET` | `/admin/verifications/pending` | Pending ID reviews |
| `POST` | `/admin/verifications/:id/approve|reject` | Verify user |
| `GET/POST` | `/admin/config/domains` | Email domain allowlist |
| `DELETE` | `/admin/config/domains/:domain` | Remove domain |
| `GET/PATCH` | `/admin/config/settings` | Maintenance mode, auto-verify |

### Utilities

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/health` | Health check |
| `POST` | `/uploads` | Image upload (multipart) |
| `GET` | `/places/autocomplete?q=` | Nominatim geocoding |

---

## 🌐 Production Deployment

### Docker Compose (recommended)

```bash
# 1. Set production values in backend/.env
#    - Strong JWT_ACCESS_SECRET, JWT_REFRESH_SECRET (32+ random chars each)
#    - Real DATABASE_URL, REDIS_URL (managed services for multi-instance)
#    - FIREBASE_* for push notifications
#    - NODE_ENV=production
#    - CORS_ORIGINS for your domains
#    - SEED_DB=false (after first boot)

# 2. Deploy
cd backend
docker compose up -d --build

# 3. Verify
curl https://your-domain.com/api/v1/health
```

### Reverse proxy (nginx example)

```nginx
server {
    listen 443 ssl;
    server_name api.yourdomain.com;

    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://localhost:5173;
        proxy_set_header Host $host;
    }
}
```

### Production checklist

- [ ] Change the default admin password immediately after seed
- [ ] Set strong `JWT_ACCESS_SECRET` / `JWT_REFRESH_SECRET` (32+ random chars each)
- [ ] Use managed PostgreSQL with connection pooling
- [ ] Use managed Redis for distributed rate limits + search cache
- [ ] Configure `FIREBASE_*` for FCM push notifications
- [ ] Set `NODE_ENV=production`, `SEED_DB=false`
- [ ] Set `CORS_ORIGINS` for production Flutter web + admin domains
- [ ] Enable HTTPS via reverse proxy
- [ ] Move file uploads to S3/R2
- [ ] Configure PostgreSQL connection pooling for multi-instance API
- [ ] Verify full flow: signup → verify → post → search → request → chat → review

---

## 🔧 Development

### Local dev (no Docker for API)

```bash
# Terminal 1: Backend
cd backend && cp .env.example .env && npm install && npm run db:push && npm run db:seed && npm run dev

# Terminal 2: Admin dashboard
cd web && npm install && npm run dev

# Terminal 3: Flutter app
cd app && cp dart_defines.example.json dart_defines.json && flutter pub get && flutter run -d chrome --web-port=7357
```

### Useful scripts

| Command | Description |
| --- | --- |
| `cd backend && npm run dev` | Start API dev server |
| `cd backend && npm run build` | Production build |
| `cd backend && npm run db:studio` | Prisma Studio GUI |
| `cd backend && npm run db:migrate` | Create migration |
| `cd backend && npm run db:push` | Sync schema to DB (dev) |
| `cd backend && npm run db:seed` | Seed demo data |
| `cd backend && npm run docker:up` | Start full Docker stack |
| `cd backend && npm run docker:down` | Stop stack |
| `cd backend && npm run docker:logs` | Follow API logs |
| `cd backend && docker compose down -v` | Wipe DB + volumes (careful) |
| `cd web && npm run build` | Production build (admin) |
| `cd app && flutter pub get` | Fetch Flutter dependencies |
| `cd app && flutter analyze` | Static analysis |

### OSRM routing engine

```bash
# First run: download Bangladesh OSM + build MLD graph
docker compose up osrm-setup
# Then run the router
curl 'http://localhost:5000/nearest/v1/driving/90.4125,23.8103'
curl 'http://localhost:5000/route/v1/driving/90.4125,23.8103;90.4254,23.8103?overview=full&geometries=geojson'
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Ensure TypeScript passes (`cd backend && npm run lint`)
4. Ensure Flutter analyzes (`cd app && flutter analyze`)
5. Commit with a clear conventional message
6. Open a pull request against `main`

**Maintainer:** [Md. Asiqur Rahman Khan](https://github.com/asiqur-rahman)

---

## 📄 License

Private — Same Way project.

---

**Same Way** — Verified Office Carpooling for Bangladesh, Self-Hosted

*Flutter · Next.js · React · PostgreSQL · OSRM*

*"Same route. Same time. Same Way."*

Built by **[Md. Asiqur Rahman Khan](https://github.com/asiqur-rahman)**
