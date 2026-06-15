# Same Way Backend

Production-ready **Next.js API backend** for the Same Way monorepo (`app/` Flutter + `web/` admin).

## Architecture

```
backend/
├── prisma/
│   ├── schema.prisma          # Full domain model (users, rides, chat, admin…)
│   └── seed.ts                # Demo admin + user + allowed domains
├── src/
│   ├── app/api/v1/            # Thin route handlers (REST)
│   ├── modules/               # Business logic per domain
│   │   ├── auth/
│   │   ├── users/
│   │   ├── rides/
│   │   ├── matching/          # Route corridor scoring (±500m)
│   │   ├── bookings/
│   │   ├── chat/
│   │   ├── notifications/
│   │   ├── reviews/
│   │   ├── admin/
│   │   └── uploads/
│   └── lib/
│       ├── auth/              # JWT + session helpers
│       ├── http/              # Errors, responses, apiRoute wrapper
│       ├── db.ts
│       └── env.ts
```

### Design principles

| Layer | Responsibility |
|-------|----------------|
| **Routes** (`app/api/v1/*`) | HTTP parsing, auth guard, call service, return JSON |
| **Modules** (`modules/*`) | Business rules, transactions, notifications |
| **Lib** (`lib/*`) | DB, JWT, shared validation, error types |
| **Prisma** | Schema, migrations, type-safe queries |

All API responses follow `{ success: true, data }` or `{ success: false, error }`.

## Quick start

### Prerequisites

- Node.js 20+
- PostgreSQL 14+

### Setup

```bash
cd sameway-backend
cp .env.example .env   # edit DB_* credentials and JWT secrets
npm install
npm run db:push        # create tables
npm run db:seed        # seed domains + demo users
npm run dev            # http://localhost:3000
```

### Seed accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@sameway.local` | `Admin@12345` |
| Demo user | `demo@sameway.local` | `Demo@12345` |

Allowed signup domain for local dev: any email (Gmail, etc.). Company domains in the allowlist get the **office verified badge** automatically.

### High-traffic / production tuning

| Variable | Default | Purpose |
|----------|---------|---------|
| `DB_POOL_MAX` | 25 | PostgreSQL connections per API instance |
| `SEARCH_CANDIDATE_CAP` | 300 | Max rides scored per search (was unbounded) |
| `SEARCH_CACHE_TTL_SEC` | 30 | Short cache for identical rush-hour searches |
| `SEARCH_BBOX_BUFFER_KM` | 18 | Geo pre-filter before corridor scoring |
| `RATE_LIMIT_ENABLED` | true | IP/user throttling on auth, search, writes |

Ride search now: **bbox DB pre-filter → capped candidate fetch → in-memory scoring → pagination**. Gender preference and `minMatchScore` are applied.

Rate limits (per minute): signup 8/IP, auth 15/IP, search 45/IP + 30/user, chat send 60/user.

For multi-instance deploys, swap in-memory rate limit/cache for **Redis** (same key scheme).

## API map (v1)

Base URL: `http://localhost:3000/api/v1`

### Auth & onboarding

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/signup` | Register (any email; company domains auto-verify) |
| POST | `/auth/signin` | Login → access + refresh tokens |
| POST | `/auth/refresh` | Rotate tokens |
| DELETE | `/auth/refresh` | Logout (invalidate refresh) |
| GET | `/auth/me` | Current user + vehicles + places |

### User profile

| Method | Endpoint | Description |
|--------|----------|-------------|
| PATCH | `/users/me` | Update profile, commute type |
| POST | `/users/me/vehicles` | Add vehicle |
| PATCH | `/users/me/vehicles/:id` | Update vehicle |
| POST | `/users/me/locations` | Upsert home/office |
| POST | `/users/me/verification` | Submit employee ID |
| PATCH | `/users/me/reminder-settings` | Notification toggles |
| POST | `/users/me/device-tokens` | Register FCM token |
| GET | `/users/:id/reviews` | Public reviews |

### Rides (offer & find)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/rides` | Post a ride (verified users) |
| GET | `/rides` | My rides as driver |
| POST | `/rides/search` | Find rides (geo pre-filter, match scoring, cache) |
| GET | `/rides/:id` | Ride detail |
| POST | `/rides/:id/request` | Rider requests seat |
| GET | `/rides/:id/requests` | Driver: incoming requests |
| POST | `/rides/:id/requests/:requestId` | Accept request |
| DELETE | `/rides/:id/requests/:requestId` | Decline request |
| POST | `/rides/:id/heading-out` | Driver broadcast |
| GET | `/rides/:id/live` | Live participant statuses |
| PATCH | `/rides/:id/participants/:userId/status` | Rider status updates |
| POST | `/rides/:id/reviews` | Rate after ride |

### Regular routes & bookings

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST | `/regular-routes` | Saved route templates |
| POST | `/regular-routes/:id/post-ride?departureAt=ISO` | Quick post from template |
| GET | `/bookings/mine?status=upcoming\|completed` | My rides as rider/driver |

### Chat & notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/chat/conversations` | Conversation list |
| GET/POST | `/chat/conversations/:id/messages` | Messages / send |
| PATCH | `/chat/conversations/:id/messages` | Mark read |
| GET | `/notifications` | Notification feed |
| PATCH | `/notifications` | Mark all read |
| PATCH | `/notifications/:id/read` | Mark one read |

### Admin

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/dashboard` | Stats |
| GET | `/admin/activity` | Activity log |
| GET/PATCH | `/admin/users`, `/admin/users/:id` | User management |
| GET | `/admin/verifications/pending` | Pending ID reviews |
| POST | `/admin/verifications/:id/approve\|reject` | Verify users |
| GET/POST | `/admin/config/domains` | Email domain allowlist |
| DELETE | `/admin/config/domains/:domain` | Remove domain |
| GET/PATCH | `/admin/config/settings` | Maintenance mode, auto-verify |

### Utilities

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/uploads` | Image upload (multipart) |
| GET | `/places/autocomplete?q=` | Google Places (optional) |

## Auth header

```
Authorization: Bearer <accessToken>
```

## Flutter integration

Point your Flutter `dio`/`http` client to:

```dart
const baseUrl = 'http://10.0.2.2:3000/api/v1'; // Android emulator
// or http://192.168.x.x:3000/api/v1 for physical device
```

Add `CORS_ORIGINS` for your Flutter web port (`7357` is preconfigured).

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run db:push` | Sync schema to DB |
| `npm run db:migrate` | Create migration |
| `npm run db:seed` | Seed data |
| `npm run db:studio` | Prisma Studio GUI |

## Scenarios covered

- Open signup (Gmail, etc.) + company-domain auto-verify badge
- Employee verification (self / admin)
- Maintenance mode (blocks signup + ride posting)
- Route matching with corridor scoring + geo bounding-box pre-filter
- Rush-hour search cache + rate limiting
- Ride request lifecycle (pending → accepted → chat)
- Ride-day live status + driver heading-out notifications
- Reviews and rating aggregation
- Admin dashboard, users, config
- File uploads for profile + employee ID
- JWT access/refresh token rotation

## Next steps (production)

- [ ] WebSocket server for real-time chat (or Firebase)
- [ ] FCM push notification delivery
- [ ] S3/R2 for uploads instead of local disk
- [ ] PostGIS for geospatial matching at scale
- [x] Rate limiting + request throttling
- [x] Search geo pre-filter + candidate cap + short TTL cache
- [ ] Redis for distributed rate limit + search cache across instances
- [ ] OpenAPI/Swagger docs

## License

Private — Same Way project.
