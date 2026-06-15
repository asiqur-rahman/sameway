type StatCardProps = {
  label: string;
  value: string | number;
  delta?: string;
};

export function StatCard({ label, value, delta }: StatCardProps) {
  return (
    <div className="card stat-card">
      <div className="label">{label}</div>
      <div className="value">{value}</div>
      {delta ? <div style={{ color: "var(--primary)", fontSize: 13, marginTop: 8 }}>{delta}</div> : null}
    </div>
  );
}
