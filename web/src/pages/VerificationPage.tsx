import { useEffect, useState } from "react";
import { api } from "../api/client";
import { DataTable } from "../components/DataTable";

type PendingUser = {
  id: string;
  fullName: string;
  workEmail: string;
  employeeIdImageUrl: string | null;
  createdAt: string;
};

function StatusBadge({ status }: { status: string }) {
  const cls =
    status === "VERIFIED"
      ? "badge badge-verified"
      : status === "REJECTED"
        ? "badge badge-rejected"
        : "badge badge-pending";
  return <span className={cls}>{status.toLowerCase()}</span>;
}

export function VerificationPage() {
  const [items, setItems] = useState<PendingUser[]>([]);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    const data = await api<PendingUser[]>("/admin/verifications/pending");
    setItems(data);
  }

  useEffect(() => {
    load().catch((e) => setError(e instanceof Error ? e.message : "Failed to load"));
  }, []);

  async function approve(id: string) {
    await api(`/admin/verifications/${id}/approve`, { method: "POST" });
    await load();
  }

  async function reject(id: string) {
    await api(`/admin/verifications/${id}/reject`, { method: "POST" });
    await load();
  }

  return (
    <>
      <header className="page-header">
        <h1>ID Verification</h1>
        <p>Admin / Verification</p>
      </header>

      {error ? <p className="error-text">{error}</p> : null}

      <p className="section-label">Pending reviews</p>
      <DataTable
        headers={["Name", "Email", "Submitted", "Action"]}
        rows={items.map((u) => [
          u.fullName,
          u.workEmail,
          new Date(u.createdAt).toLocaleDateString(),
          <div className="actions" key={u.id}>
            {u.employeeIdImageUrl ? (
              <a href={u.employeeIdImageUrl} target="_blank" rel="noreferrer" className="btn btn-secondary">
                View ID
              </a>
            ) : null}
            <button type="button" className="btn btn-primary" onClick={() => approve(u.id)}>
              Approve
            </button>
            <button type="button" className="btn btn-danger" onClick={() => reject(u.id)}>
              Reject
            </button>
          </div>,
        ])}
      />
    </>
  );
}

export { StatusBadge };
