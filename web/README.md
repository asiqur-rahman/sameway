# SameWay Admin (React)

Browser admin dashboard for SameWay. Talks to `../backend/` at `/api/v1`.

## Pages

- **Dashboard** — stats + activity log
- **Verification** — approve/reject employee IDs
- **Users** — user list
- **Config** — domain allowlist, maintenance mode

## Run

```bash
npm install
npm run dev      # http://localhost:5173
```

Requires the backend running on port 3000 (Vite proxies `/api`).

**Login:** `admin@sameway.local` / `Admin@12345` (after `npm run db:seed` in backend)

## Build

```bash
npm run build
npm run preview
```
