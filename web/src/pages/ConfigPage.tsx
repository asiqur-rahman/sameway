import { useEffect, useState } from "react";
import { api } from "../api/client";

type Domain = { id: string; domain: string; autoVerify: boolean };
type Settings = {
  maintenanceMode: boolean;
  autoVerifyKnownDomains: boolean;
};

export function ConfigPage() {
  const [domains, setDomains] = useState<Domain[]>([]);
  const [settings, setSettings] = useState<Settings | null>(null);
  const [newDomain, setNewDomain] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function load() {
    const [d, s] = await Promise.all([
      api<Domain[]>("/admin/config/domains"),
      api<Settings>("/admin/config/settings"),
    ]);
    setDomains(d);
    setSettings(s);
  }

  useEffect(() => {
    load().catch((e) => setError(e instanceof Error ? e.message : "Failed to load"));
  }, []);

  async function addDomain() {
    if (!newDomain.trim()) return;
    await api("/admin/config/domains", {
      method: "POST",
      body: JSON.stringify({ domain: newDomain.trim(), autoVerify: false }),
    });
    setNewDomain("");
    await load();
  }

  async function removeDomain(domain: string) {
    await api(`/admin/config/domains/${encodeURIComponent(domain)}`, { method: "DELETE" });
    await load();
  }

  async function updateSettings(patch: Partial<Settings>) {
    if (!settings) return;
    const next = { ...settings, ...patch };
    const updated = await api<Settings>("/admin/config/settings", {
      method: "PATCH",
      body: JSON.stringify(patch),
    });
    setSettings(updated ?? next);
  }

  return (
    <>
      <header className="page-header">
        <h1>System Config</h1>
        <p>Admin / Config</p>
      </header>

      {error ? <p className="error-text">{error}</p> : null}

      <div className="config-grid">
        <section>
          <p className="section-label">Domain allowlist</p>
          <div className="card" style={{ padding: 20 }}>
            <div style={{ display: "flex", gap: 8 }}>
              <input
                className="input"
                placeholder="company.com"
                value={newDomain}
                onChange={(e) => setNewDomain(e.target.value)}
              />
              <button type="button" className="btn btn-primary" onClick={addDomain}>
                Add
              </button>
            </div>
            <div className="domain-chips">
              {domains.map((d) => (
                <span key={d.id} className="domain-chip">
                  {d.domain}
                  {d.autoVerify ? " (auto)" : ""}
                  <button
                    type="button"
                    style={{ marginLeft: 8, border: "none", background: "transparent", cursor: "pointer" }}
                    onClick={() => removeDomain(d.domain)}
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          </div>
        </section>

        <section>
          <p className="section-label">System settings</p>
          <div className="card" style={{ padding: 20 }}>
            <div className="toggle-row">
              <div>
                <strong>Auto-verify known domains</strong>
                <div style={{ color: "var(--text-muted)", fontSize: 13 }}>
                  Automatically verify users from allowlisted domains
                </div>
              </div>
              <input
                type="checkbox"
                checked={settings?.autoVerifyKnownDomains ?? false}
                onChange={(e) => updateSettings({ autoVerifyKnownDomains: e.target.checked })}
              />
            </div>
            <div className="toggle-row">
              <div>
                <strong>Maintenance mode</strong>
                <div style={{ color: "var(--text-muted)", fontSize: 13 }}>
                  Block signups and ride posting
                </div>
              </div>
              <input
                type="checkbox"
                checked={settings?.maintenanceMode ?? false}
                onChange={(e) => updateSettings({ maintenanceMode: e.target.checked })}
              />
            </div>
          </div>
        </section>
      </div>
    </>
  );
}
