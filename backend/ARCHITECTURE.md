# Same Way Backend Architecture

Clean, layered architecture designed for **high commute-hour traffic** and **Flutter app integration**.

## Layers

```
src/
├── app/api/v1/              # HTTP adapters (thin route handlers)
├── application/
│   ├── container.ts         # Dependency injection (singletons)
│   ├── use-cases/           # Application orchestration
│   └── mappers/             # Stable API DTOs (Flutter contract)
├── domain/
│   ├── ports/               # Cache, rate-limit interfaces
│   └── repositories/        # Persistence contracts
├── infrastructure/
│   ├── persistence/         # Prisma repository implementations
│   ├── cache/               # Memory (dev) → Redis (prod)
│   ├── rate-limit/          # Memory (dev) → Redis (prod)
│   └── outbox/              # Async notification queue
├── modules/                 # Legacy service facades (delegate to use-cases)
└── lib/                     # Cross-cutting: auth, db, env, http
```

## Request flow

```
Client → middleware (CORS + rate limit)
      → route handler (auth + Zod validation)
      → module service OR use-case
      → repository / Prisma
      → mapper → { success, data }
```

## High-volume design (1k–10k+ users)

| Concern | Implementation |
|---------|----------------|
| Ride search | Geo bbox DB pre-filter → cap 300 candidates → score → 30s TTL cache per user+corridor |
| Search cache invalidation | Prefix `search:` only — geocode cache stays warm when new rides post |
| Geocoding | Google API + **24h server cache** (shared across all users for same address) |
| Rate limits | Per-IP + per-user on auth, search, chat — use Redis at multi-instance |
| DB pool | Tunable `DB_POOL_MAX` (raise to 50–100 under load) |
| Notifications | In-app row + `NotificationOutbox` for async FCM workers |
| Cache store | `REDIS_URL` → Redis; else bounded in-memory (`CACHE_MAX_ENTRIES=20000`) |
| User places | One row per label per user in `Place` — scales linearly with users |

## Environment (production — thousands of users)

```env
DB_POOL_MAX=50
SEARCH_CANDIDATE_CAP=300
SEARCH_CACHE_TTL_SEC=30
SEARCH_BBOX_BUFFER_KM=18
RATE_LIMIT_ENABLED=true
REDIS_URL=redis://localhost:6379
GEOCODE_CACHE_TTL_SEC=86400
CACHE_MAX_ENTRIES=20000
GOOGLE_MAPS_API_KEY=...
```

## Scaling path

1. **Single instance (dev):** in-memory cache + rate limits
2. **Production (1k+ users):** Redis for shared search + geocode cache across API replicas
3. **Outbox worker:** poll `NotificationOutbox` → FCM (separate process, horizontal scale)
4. **PostGIS:** when OPEN rides exceed ~50k nationally, replace bbox heuristic
5. **Read replicas:** route search `findMany` to replica if DB becomes hot spot

## Flutter alignment

| Flutter model | API |
|---------------|-----|
| `FindRideListing` | `POST /rides/search` → `RideListingDto[]` |
| `UserProfile` + phases | `GET /auth/me` → `onboardingPhase` inferred |
| `CommutePreferences` | `PATCH /users/me/commute-preferences` |
| `VehicleInfo` extras | `usuallyLeave`, `latestDepart` on vehicle |
| `WALK` commute | `CommuteType.WALK` in schema |
| Work verification | `GET /users/me/work-verification` |
| My rides | `GET /bookings/mine` → Flutter-shaped bookings |
| Cancel / complete ride | `DELETE /rides/:id`, `PATCH /rides/:id` |

## Commands

```bash
npm run db:push      # apply schema
npm run db:seed      # seed domains + demo users
npm run dev          # http://localhost:3000
npm run build        # production build
```
