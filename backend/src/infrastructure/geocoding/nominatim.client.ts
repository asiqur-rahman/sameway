import { env } from "@/lib/env";

type NominatimSearchHit = {
  place_id: number;
  lat: string;
  lon: string;
  display_name: string;
};

type NominatimReverseHit = {
  place_id: number;
  lat: string;
  lon: string;
  display_name: string;
};

/** Public Nominatim allows ~1 req/s — serialize calls. */
let lastRequestAt = 0;

async function throttleNominatim() {
  const minGapMs = 1100;
  const now = Date.now();
  const wait = lastRequestAt + minGapMs - now;
  if (wait > 0) await new Promise((r) => setTimeout(r, wait));
  lastRequestAt = Date.now();
}

function headers() {
  return {
    "User-Agent": env.NOMINATIM_USER_AGENT,
    Accept: "application/json",
    "Accept-Language": "en",
  };
}

export async function nominatimSearch(query: string, limit = 5): Promise<NominatimSearchHit[]> {
  await throttleNominatim();
  const url = new URL(`${env.NOMINATIM_BASE_URL}/search`);
  url.searchParams.set("q", query);
  url.searchParams.set("format", "json");
  url.searchParams.set("limit", String(limit));
  url.searchParams.set("countrycodes", "bd");
  url.searchParams.set("addressdetails", "0");

  const res = await fetch(url, { headers: headers() });
  if (!res.ok) return [];
  const data = (await res.json()) as NominatimSearchHit[];
  return Array.isArray(data) ? data : [];
}

export async function nominatimReverse(lat: number, lng: number): Promise<NominatimReverseHit | null> {
  await throttleNominatim();
  const url = new URL(`${env.NOMINATIM_BASE_URL}/reverse`);
  url.searchParams.set("lat", String(lat));
  url.searchParams.set("lon", String(lng));
  url.searchParams.set("format", "json");
  url.searchParams.set("addressdetails", "0");

  const res = await fetch(url, { headers: headers() });
  if (!res.ok) return null;
  const data = (await res.json()) as NominatimReverseHit & { error?: string };
  if (data.error || !data.display_name) return null;
  return data;
}

export async function nominatimLookup(placeId: string): Promise<NominatimSearchHit | null> {
  await throttleNominatim();
  const url = new URL(`${env.NOMINATIM_BASE_URL}/lookup`);
  url.searchParams.set("osm_ids", placeId);
  url.searchParams.set("format", "json");

  const res = await fetch(url, { headers: headers() });
  if (!res.ok) return null;
  const data = (await res.json()) as NominatimSearchHit[];
  return data[0] ?? null;
}
