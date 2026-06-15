import type { GeoPoint } from "@/lib/shared";

/** ~111 km per degree latitude; longitude shrinks by cos(lat). */
const KM_PER_DEG_LAT = 111;

export type BoundingBox = {
  minLat: number;
  maxLat: number;
  minLng: number;
  maxLng: number;
};

export function kmToLatDegrees(km: number): number {
  return km / KM_PER_DEG_LAT;
}

export function kmToLngDegrees(km: number, atLat: number): number {
  const cosLat = Math.cos((atLat * Math.PI) / 180);
  return km / (KM_PER_DEG_LAT * Math.max(cosLat, 0.2));
}

/**
 * Expand rider from/to into a search bounding box.
 * Default 18 km buffer covers typical Dhaka corridor detours.
 */
export function expandSearchBBox(
  fromLat: number,
  fromLng: number,
  toLat: number,
  toLng: number,
  bufferKm = 18,
): BoundingBox {
  const centerLat = (fromLat + toLat) / 2;
  const latPad = kmToLatDegrees(bufferKm);
  const lngPad = kmToLngDegrees(bufferKm, centerLat);

  return {
    minLat: Math.min(fromLat, toLat) - latPad,
    maxLat: Math.max(fromLat, toLat) + latPad,
    minLng: Math.min(fromLng, toLng) - lngPad,
    maxLng: Math.max(fromLng, toLng) + lngPad,
  };
}

export function pointInBBox(point: Pick<GeoPoint, "lat" | "lng">, box: BoundingBox): boolean {
  return (
    point.lat >= box.minLat &&
    point.lat <= box.maxLat &&
    point.lng >= box.minLng &&
    point.lng <= box.maxLng
  );
}

/** Axis-aligned bbox overlap for a driver's start→end segment. */
export function segmentOverlapsBBox(
  startLat: number,
  startLng: number,
  endLat: number,
  endLng: number,
  box: BoundingBox,
): boolean {
  const segMinLat = Math.min(startLat, endLat);
  const segMaxLat = Math.max(startLat, endLat);
  const segMinLng = Math.min(startLng, endLng);
  const segMaxLng = Math.max(startLng, endLng);

  if (segMaxLat < box.minLat || segMinLat > box.maxLat) return false;
  if (segMaxLng < box.minLng || segMinLng > box.maxLng) return false;

  if (pointInBBox({ lat: startLat, lng: startLng }, box)) return true;
  if (pointInBBox({ lat: endLat, lng: endLng }, box)) return true;

  return true;
}

/** Grid key for short-lived search result cache (2-decimal ≈ 1.1 km). */
export function searchCacheKey(input: {
  fromLat: number;
  fromLng: number;
  toLat: number;
  toLng: number;
  vehicleFilter: string;
  genderPreference: string;
  maxWalkingMinutes: number;
  minMatchScore: number;
  page: number;
  limit: number;
}): string {
  const round = (n: number) => n.toFixed(2);
  return [
    round(input.fromLat),
    round(input.fromLng),
    round(input.toLat),
    round(input.toLng),
    input.vehicleFilter,
    input.genderPreference,
    input.maxWalkingMinutes,
    input.minMatchScore,
    input.page,
    input.limit,
  ].join(":");
}
