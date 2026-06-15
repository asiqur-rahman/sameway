export default function Home() {
  const endpoints = [
    "GET  /api/v1/health",
    "POST /api/v1/auth/signup | signin | refresh",
    "GET  /api/v1/auth/me",
    "PATCH /api/v1/users/me",
    "POST /api/v1/users/me/vehicles | locations | verification",
    "GET/POST /api/v1/rides | POST /api/v1/rides/search",
    "POST /api/v1/rides/:id/request",
    "GET  /api/v1/bookings/mine",
    "GET/POST /api/v1/chat/conversations/:id/messages",
    "GET  /api/v1/notifications",
    "GET  /api/v1/admin/dashboard (admin)",
  ];

  return (
    <main style={{ fontFamily: "system-ui", maxWidth: 720, margin: "48px auto", padding: 24 }}>
      <h1 style={{ color: "#10B981" }}>SameWay API</h1>
      <p>Backend for the SameWay carpool app. All routes are under <code>/api/v1</code>.</p>
      <h2>Quick start</h2>
      <pre style={{ background: "#F8FAFC", padding: 16, borderRadius: 8 }}>
        {`cp .env.example .env
npm run db:push
npm run db:seed
npm run dev`}
      </pre>
      <h2>Health check</h2>
      <p>
        <a href="/api/v1/health">/api/v1/health</a>
      </p>
      <h2>Key endpoints</h2>
      <ul>
        {endpoints.map((e) => (
          <li key={e}>
            <code>{e}</code>
          </li>
        ))}
      </ul>
      <p style={{ color: "#94A3B8" }}>See README.md for the full API map.</p>
    </main>
  );
}
