import { useEffect, useState } from "react";
import { api } from "../api/client";
import { DataTable } from "../components/DataTable";
import { StatCard } from "../components/StatCard";

type Stats = {
  users: number;
  pendingVerifications: number;
  activeRides: number;
  completedRides: number;
};

type Activity = {
  id: string;
  event: string;
  createdAt: string;
  userId: string | null;
};

export function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [activity, setActivity] = useState<Activity[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([
      api<Stats>("/admin/dashboard"),
      api<Activity[]>("/admin/activity"),
    ])
      .then(([s, a]) => {
        setStats(s);
        setActivity(a);
      })
      .catch((e) => setError(e instanceof Error ? e.message : "Failed to load"));
  }, []);

  return (
    <>
      <header className="page-header">
        <h1>Dashboard</h1>
        <p>Admin / Dashboard</p>
      </header>

      {error ? <p className="error-text">{error}</p> : null}

      <div className="stat-grid">
        <StatCard label="Total Users" value={stats?.users ?? "—"} />
        <StatCard label="Active Rides" value={stats?.activeRides ?? "—"} />
        <StatCard label="Pending Verifications" value={stats?.pendingVerifications ?? "—"} />
        <StatCard label="Completed Rides" value={stats?.completedRides ?? "—"} />
      </div>

      <p className="section-label">Recent activity</p>
      <DataTable
        headers={["Event", "User", "Time"]}
        rows={activity.map((a) => [
          a.event,
          a.userId ?? "—",
          new Date(a.createdAt).toLocaleString(),
        ])}
      />
    </>
  );
}
