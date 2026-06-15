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

## High-volume design

| Concern | Implementation |
|---------|----------------|
| Ride search | Geo bbox DB pre-filter → cap 300 candidates → score → 30s cache |
| Rate limits | Per-IP + per-user on auth, search, chat (swap to Redis at scale) |
| DB pool | Tunable `DB_POOL_MAX` (default 25) |
| Notifications | In-app row + `NotificationOutbox` for FCM workers |
| Cache | `ICacheStore` port — `MemoryCacheStore` today, Redis tomorrow |

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

## Environment (production tuning)

```env
DB_POOL_MAX=25
SEARCH_CANDIDATE_CAP=300
SEARCH_CACHE_TTL_SEC=30
SEARCH_BBOX_BUFFER_KM=18
RATE_LIMIT_ENABLED=true
# REDIS_URL=redis://...  # future: swap cache + rate limit stores
```

## Scaling path

1. **Single instance** (current): in-memory cache + rate limits
2. **Multi-instance**: Redis for `ICacheStore` + `IRateLimitStore`
3. **Outbox worker**: poll `NotificationOutbox` → FCM/APNs
4. **PostGIS**: replace bbox heuristic for national-scale search
5. **WebSocket**: real-time chat + live ride status

## Commands

```bash
npm run db:push      # apply schema
npm run db:seed      # seed domains + demo users
npm run dev          # http://localhost:3000
npm run build        # production build
```
