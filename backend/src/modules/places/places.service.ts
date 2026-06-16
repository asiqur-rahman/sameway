import { createHash } from "crypto";
import { getCacheStore } from "@/infrastructure/cache/create-cache-store";
import { env } from "@/lib/env";
import { ServiceUnavailableError, ValidationError } from "@/lib/http/errors";

export type ResolvedPlace = {
  address: string;
  lat: number;
  lng: number;
  placeId?: string;
};

const GEO_FORWARD_PREFIX = "geo:fwd:";
const GEO_REVERSE_PREFIX = "geo:rev:";

/** Reject unset map pins (0,0) used as placeholders. */
export function isValidCoordinate(lat: number, lng: number): boolean {
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false;
  if (lat === 0 && lng === 0) return false;
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

function assertMapsKey() {
  if (!env.GOOGLE_MAPS_API_KEY) {
    throw new ServiceUnavailableError("Maps geocoding is not configured on the server");
  }
}

function normalizeAddress(query: string) {
  return query.trim().toLowerCase().replace(/\s+/g, " ");
}

function geocodeCacheKey(query: string) {
  const hash = createHash("sha256").update(normalizeAddress(query)).digest("hex").slice(0, 24);
  return `${GEO_FORWARD_PREFIX}${hash}`;
}

function reverseCacheKey(lat: number, lng: number) {
  return `${GEO_REVERSE_PREFIX}${lat.toFixed(4)},${lng.toFixed(4)}`;
}

async function cachedGeocode<T>(key: string, loader: () => Promise<T>): Promise<T> {
  const cache = getCacheStore();
  const hit = await cache.get<T>(key);
  if (hit) return hit;
  const value = await loader();
  await cache.set(key, value, env.GEOCODE_CACHE_TTL_SEC * 1000);
  return value;
}

export async function reverseGeocode(lat: number, lng: number): Promise<ResolvedPlace> {
  if (!isValidCoordinate(lat, lng)) {
    throw new ValidationError({
      formErrors: ["Invalid coordinates"],
      fieldErrors: { lat: ["Latitude/longitude required"] },
    });
  }

  return cachedGeocode(reverseCacheKey(lat, lng), async () => {
    assertMapsKey();

    const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
    url.searchParams.set("latlng", `${lat},${lng}`);
    url.searchParams.set("key", env.GOOGLE_MAPS_API_KEY!);
    url.searchParams.set("region", "bd");

    const res = await fetch(url);
    const data = (await res.json()) as {
      status: string;
      results?: Array<{ formatted_address: string; place_id: string }>;
    };

    if (data.status !== "OK" || !data.results?.length) {
      throw new ValidationError({
        formErrors: ["Could not resolve address for this location"],
        fieldErrors: {},
      });
    }

    const best = data.results[0];
    return {
      address: best.formatted_address,
      lat,
      lng,
      placeId: best.place_id,
    };
  });
}

export async function geocodeAddress(query: string): Promise<ResolvedPlace> {
  const trimmed = query.trim();
  if (trimmed.length < 3) {
    throw new ValidationError({
      formErrors: ["Enter a longer address to geocode"],
      fieldErrors: {},
    });
  }

  return cachedGeocode(geocodeCacheKey(trimmed), async () => {
    assertMapsKey();

    const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
    url.searchParams.set("address", trimmed);
    url.searchParams.set("key", env.GOOGLE_MAPS_API_KEY!);
    url.searchParams.set("components", "country:BD");
    url.searchParams.set("region", "bd");

    const res = await fetch(url);
    const data = (await res.json()) as {
      status: string;
      results?: Array<{
        formatted_address: string;
        place_id: string;
        geometry: { location: { lat: number; lng: number } };
      }>;
    };

    if (data.status !== "OK" || !data.results?.length) {
      throw new ValidationError({
        formErrors: ["Address not found. Pin the location on the map instead."],
        fieldErrors: {},
      });
    }

    const best = data.results[0];
    return {
      address: best.formatted_address,
      lat: best.geometry.location.lat,
      lng: best.geometry.location.lng,
      placeId: best.place_id,
    };
  });
}

export async function autocompletePlaces(query: string) {
  assertMapsKey();

  const url = new URL("https://maps.googleapis.com/maps/api/place/autocomplete/json");
  url.searchParams.set("input", query);
  url.searchParams.set("key", env.GOOGLE_MAPS_API_KEY!);
  url.searchParams.set("components", "country:bd");

  const res = await fetch(url);
  const data = await res.json();
  return data;
}
