const API_BASE = import.meta.env.VITE_API_URL ?? "/api/v1";

export type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: { message: string; code?: string } };

function getToken(): string | null {
  return localStorage.getItem("accessToken");
}

export function setTokens(accessToken: string, refreshToken: string) {
  localStorage.setItem("accessToken", accessToken);
  localStorage.setItem("refreshToken", refreshToken);
}

export function clearTokens() {
  localStorage.removeItem("accessToken");
  localStorage.removeItem("refreshToken");
}

export async function api<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const headers = new Headers(options.headers);
  if (!headers.has("Content-Type") && options.body) {
    headers.set("Content-Type", "application/json");
  }
  const token = getToken();
  if (token) headers.set("Authorization", `Bearer ${token}`);

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  const json = (await res.json()) as ApiResponse<T>;

  if (!json.success) {
    throw new Error(json.error?.message ?? "Request failed");
  }
  return json.data;
}

export async function signin(workEmail: string, password: string) {
  return api<{
    user: { id: string; fullName: string; role: string };
    tokens: { accessToken: string; refreshToken: string };
  }>("/auth/signin", {
    method: "POST",
    body: JSON.stringify({ workEmail, password }),
  });
}
