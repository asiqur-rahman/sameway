import type { GeoPoint } from "@/lib/shared";

const EARTH_RADIUS_M = 6_371_000;
const MATCH_CORRIDOR_M = 500;

function toRad(deg: number) {
  return (deg * Math.PI) / 180;
}

/** Haversine distance in meters between two lat/lng points. */
export function distanceMeters(a: GeoPoint, b: GeoPoint): number {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_M * Math.asin(Math.sqrt(h));
}

export type RouteSegment = {
  start: GeoPoint;
  end: GeoPoint;
};

/** Build ordered segments from start → stops → end. */
export function buildSegments(
  start: GeoPoint,
  end: GeoPoint,
  stops: GeoPoint[] = [],
): RouteSegment[] {
  const points = [start, ...stops, end];
  const segments: RouteSegment[] = [];
  for (let i = 0; i < points.length - 1; i++) {
    segments.push({ start: points[i], end: points[i + 1] });
  }
  return segments;
}

/** Minimum distance from a point to any segment corridor (simplified). */
function pointToSegmentDistanceM(point: GeoPoint, segment: RouteSegment): number {
  const dStart = distanceMeters(point, segment.start);
  const dEnd = distanceMeters(point, segment.end);
  const segLen = distanceMeters(segment.start, segment.end);
  if (segLen === 0) return dStart;
  // Project onto segment midpoint heuristic for corridor matching
  const mid: GeoPoint = {
    address: "",
    lat: (segment.start.lat + segment.end.lat) / 2,
    lng: (segment.start.lng + segment.end.lng) / 2,
  };
  return Math.min(dStart, dEnd, distanceMeters(point, mid));
}

export type MatchInput = {
  riderFrom: GeoPoint;
  riderTo: GeoPoint;
  driverSegments: RouteSegment[];
};

/**
 * Score how well a rider's trip fits a driver's route.
 * Returns 0–100; riders within ±500m corridor score higher.
 */
export function scoreRouteMatch(input: MatchInput): number {
  const { riderFrom, riderTo, driverSegments } = input;
  if (driverSegments.length === 0) return 0;

  let bestPickup = Infinity;
  let bestDropoff = Infinity;

  for (const seg of driverSegments) {
    bestPickup = Math.min(bestPickup, pointToSegmentDistanceM(riderFrom, seg));
    bestDropoff = Math.min(bestDropoff, pointToSegmentDistanceM(riderTo, seg));
  }

  const avgDist = (bestPickup + bestDropoff) / 2;
  if (avgDist > MATCH_CORRIDOR_M * 2) return 0;

  const score = Math.max(0, 100 - (avgDist / MATCH_CORRIDOR_M) * 50);
  return Math.round(score * 10) / 10;
}

/** Rough walking time estimate at 5 km/h. */
export function walkingMinutes(distanceM: number): number {
  return Math.ceil(distanceM / (5000 / 60));
}
