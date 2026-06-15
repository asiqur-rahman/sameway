import { useEffect, useState } from "react";
import { api } from "../api/client";
import { DataTable } from "../components/DataTable";
import { StatusBadge } from "./VerificationPage";

type UserRow = {
  id: string;
  fullName: string;
  workEmail: string;
  verificationStatus: string;
  rating: number;
  role: string;
};

type UsersResponse = {
  items: UserRow[];
  total: number;
};

export function UsersPage() {
  const [users, setUsers] = useState<UserRow[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api<UsersResponse>("/admin/users")
      .then((res) => setUsers(res.items))
      .catch((e) => setError(e instanceof Error ? e.message : "Failed to load"));
  }, []);

  return (
    <>
      <header className="page-header">
        <h1>User Management</h1>
        <p>Admin / Users</p>
      </header>

      {error ? <p className="error-text">{error}</p> : null}

      <p className="section-label">All users</p>
      <DataTable
        headers={["Name", "Email", "Status", "Role", "Rating"]}
        rows={users.map((u) => [
          u.fullName,
          u.workEmail,
          <StatusBadge key={`s-${u.id}`} status={u.verificationStatus} />,
          u.role,
          u.rating ? u.rating.toFixed(1) : "—",
        ])}
      />
    </>
  );
}
