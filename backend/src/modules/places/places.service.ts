import { createHash } from "crypto";
import {
  nominatimLookup,
  nominatimReverse,
  nominatimSearch,
} from "@/infrastructure/geocoding/nominatim.client";
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

function assertGoogleMapsKey() {
  if (!env.GOOGLE_MAPS_API_KEY) {
    throw new ServiceUnavailableError("Google geocoding is not configured (set GOOGLE_MAPS_API_KEY)");
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

async function googleReverseGeocode(lat: number, lng: number): Promise<ResolvedPlace> {
  assertGoogleMapsKey();
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
  return { address: best.formatted_address, lat, lng, placeId: best.place_id };
}

async function googleGeocodeAddress(query: string): Promise<ResolvedPlace> {
  assertGoogleMapsKey();
  const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
  url.searchParams.set("address", query);
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
}

async function nominatimReverseGeocode(lat: number, lng: number): Promise<ResolvedPlace> {
  const hit = await nominatimReverse(lat, lng);
  if (!hit) {
    return {
      address: `Pinned location (${lat.toFixed(5)}, ${lng.toFixed(5)})`,
      lat,
      lng,
    };
  }
  return {
    address: hit.display_name,
    lat: Number(hit.lat),
    lng: Number(hit.lon),
    placeId: String(hit.place_id),
  };
}

async function nominatimGeocodeAddress(query: string): Promise<ResolvedPlace> {
  const hits = await nominatimSearch(query, 1);
  if (!hits.length) {
    throw new ValidationError({
      formErrors: ["Address not found. Pin the location on the map instead."],
      fieldErrors: {},
    });
  }
  const best = hits[0];
  return {
    address: best.display_name,
    lat: Number(best.lat),
    lng: Number(best.lon),
    placeId: String(best.place_id),
  };
}

export async function reverseGeocode(lat: number, lng: number): Promise<ResolvedPlace> {
  if (!isValidCoordinate(lat, lng)) {
    throw new ValidationError({
      formErrors: ["Invalid coordinates"],
      fieldErrors: { lat: ["Latitude/longitude required"] },
    });
  }

  return cachedGeocode(reverseCacheKey(lat, lng), async () => {
    if (env.GEO_PROVIDER === "google") return googleReverseGeocode(lat, lng);
    return nominatimReverseGeocode(lat, lng);
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
    if (env.GEO_PROVIDER === "google") return googleGeocodeAddress(trimmed);
    return nominatimGeocodeAddress(trimmed);
  });
}

export async function autocompletePlaces(query: string) {
  if (env.GEO_PROVIDER === "google") {
    assertGoogleMapsKey();
    const url = new URL("https://maps.googleapis.com/maps/api/place/autocomplete/json");
    url.searchParams.set("input", query);
    url.searchParams.set("key", env.GOOGLE_MAPS_API_KEY!);
    url.searchParams.set("components", "country:bd");
    const res = await fetch(url);
    return res.json();
  }

  const hits = await nominatimSearch(query, 6);
  return {
    provider: "nominatim",
    predictions: hits.map((h) => ({
      description: h.display_name,
      place_id: String(h.place_id),
      lat: Number(h.lat),
      lng: Number(h.lon),
    })),
  };
}

export async function placeDetails(placeId: string): Promise<ResolvedPlace> {
  const cacheKey = `geo:details:${placeId}`;
  const cache = getCacheStore();
  const hit = await cache.get<ResolvedPlace>(cacheKey);
  if (hit) return hit;

  let result: ResolvedPlace;

  if (env.GEO_PROVIDER === "google") {
    assertGoogleMapsKey();
    const url = new URL("https://maps.googleapis.com/maps/api/place/details/json");
    url.searchParams.set("place_id", placeId);
    url.searchParams.set("fields", "formatted_address,geometry,place_id");
    url.searchParams.set("key", env.GOOGLE_MAPS_API_KEY!);

    const res = await fetch(url);
    const data = (await res.json()) as {
      status: string;
      result?: {
        formatted_address: string;
        place_id: string;
        geometry: { location: { lat: number; lng: number } };
      };
    };

    if (data.status !== "OK" || !data.result) {
      throw new ValidationError({ formErrors: ["Place not found"], fieldErrors: {} });
    }

    result = {
      address: data.result.formatted_address,
      lat: data.result.geometry.location.lat,
      lng: data.result.geometry.location.lng,
      placeId: data.result.place_id,
    };
  } else {
    const lookup = await nominatimLookup(placeId);
    if (!lookup) {
      throw new ValidationError({ formErrors: ["Place not found"], fieldErrors: {} });
    }
    result = {
      address: lookup.display_name,
      lat: Number(lookup.lat),
      lng: Number(lookup.lon),
      placeId: String(lookup.place_id),
    };
  }

  await cache.set(cacheKey, result, env.GEOCODE_CACHE_TTL_SEC * 1000);
  return result;
}
