import type { GeoPoint } from "@/lib/shared";

const EARTH_RADIUS_M = 6_371_000;

/**
 * Corridor half-widths.
 * A rider within PICKUP_CORRIDOR_M of the driver's route path scores near 100.
 * Using exponential decay: score = 100 * exp(-d / sigma)
 *   d=0m   → 100   (on the route)
 *   d=250m → ~61   (quarter corridor)
 *   d=500m → ~37   (half corridor)
 *   d=1km  → ~14   (1x corridor, still shows as ~14% match)
 *   d=2km  → ~2    (effectively filtered by minMatchScore)
 */
const PICKUP_SIGMA_M = 500;
const DROPOFF_SIGMA_M = 600;

/** Multiplier applied when rider travels opposite direction to driver. */
const WRONG_DIRECTION_MULT = 0.15;

function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

/** Haversine great-circle distance in metres. */
export function distanceMeters(a: Pick<GeoPoint, "lat" | "lng">, b: Pick<GeoPoint, "lat" | "lng">): number {
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

/** Build ordered segments from start → stops → end (used as fallback without OSRM). */
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

/**
 * Minimum perpendicular distance from a point to a line segment,
 * using a flat-earth Cartesian projection (valid for routes <200 km).
 *
 * Previous implementation used only start/end/midpoint distance,
 * which gave grossly wrong answers for points anywhere except near
 * those three discrete samples.
 */
function pointToSegmentResult(
  point: Pick<GeoPoint, "lat" | "lng">,
  segment: RouteSegment,
): { distM: number; t: number; nearest: { lat: number; lng: number } } {
  const A = segment.start;
  const B = segment.end;

  // Flat-earth Cartesian — valid up to ~200 km, accurate to <0.1% for 20 km Dhaka routes.
  const midLat = (A.lat + B.lat) / 2;
  const mPerLat = (Math.PI * EARTH_RADIUS_M) / 180;
  const mPerLng = mPerLat * Math.cos(toRad(midLat));

  const ax = A.lng * mPerLng,  ay = A.lat * mPerLat;
  const bx = B.lng * mPerLng,  by = B.lat * mPerLat;
  const px = point.lng * mPerLng, py = point.lat * mPerLat;

  const dx = bx - ax;
  const dy = by - ay;
  const lenSq = dx * dx + dy * dy;

  // Degenerate segment (same start and end point)
  if (lenSq < 1e-6) {
    return { distM: distanceMeters(point, A), t: 0, nearest: { lat: A.lat, lng: A.lng } };
  }

  // Parameter t ∈ [0, 1] of the projection of P onto line AB
  const t = Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / lenSq));

  const nearest = {
    lat: A.lat + t * (B.lat - A.lat),
    lng: A.lng + t * (B.lng - A.lng),
  };

  return {
    distM: distanceMeters(point, nearest),
    t,
    nearest,
  };
}

type NearestResult = {
  distM: number;
  segIndex: number;
  nearest: { lat: number; lng: number };
};

/**
 * Find the nearest point on an entire polyline (list of segments) to a given point.
 * Returns the distance, which segment index it falls on, and the nearest coordinates.
 */
function nearestOnPolyline(
  point: Pick<GeoPoint, "lat" | "lng">,
  segments: RouteSegment[],
): NearestResult {
  let best: NearestResult = {
    distM: Infinity,
    segIndex: 0,
    nearest: { lat: segments[0].start.lat, lng: segments[0].start.lng },
  };

  for (let i = 0; i < segments.length; i++) {
    const result = pointToSegmentResult(point, segments[i]);
    if (result.distM < best.distM) {
      best = { distM: result.distM, segIndex: i, nearest: result.nearest };
    }
  }

  return best;
}

export type MatchInput = {
  riderFrom: GeoPoint;
  riderTo: GeoPoint;
  driverSegments: RouteSegment[];
};

/**
 * Score how well a rider's trip fits a driver's road route.
 *
 * Algorithm (replaces the previous straight-line midpoint heuristic):
 *
 * 1. Find the nearest point on the driver's polyline to the rider's pickup.
 * 2. Find the nearest point on the driver's polyline to the rider's dropoff.
 * 3. Check direction: the pickup's segment index must be ≤ the dropoff's segment index.
 *    A rider going Uttara→Motijheel must not match a driver going Motijheel→Uttara.
 * 4. Score each using exponential corridor decay:
 *      score = 100 × exp(−distance / sigma)
 *    This gives smooth scores rather than a cliff at 500 m.
 * 5. Wrong-direction matches are heavily penalised (×0.15) rather than zeroed,
 *    because the driver may offer partial route flexibility.
 *
 * Returns 0–100.
 */
export function scoreRouteMatch(input: MatchInput): number {
  const { riderFrom, riderTo, driverSegments } = input;
  if (driverSegments.length === 0) return 0;

  const pickup  = nearestOnPolyline(riderFrom, driverSegments);
  const dropoff = nearestOnPolyline(riderTo,   driverSegments);

  // Exponential corridor scores
  const pickupScore  = 100 * Math.exp(-pickup.distM  / PICKUP_SIGMA_M);
  const dropoffScore = 100 * Math.exp(-dropoff.distM / DROPOFF_SIGMA_M);
  const corridorScore = (pickupScore + dropoffScore) / 2;

  // Direction: pickup segment must come before or at the dropoff segment
  const directionOk = pickup.segIndex <= dropoff.segIndex;
  const directionMult = directionOk ? 1.0 : WRONG_DIRECTION_MULT;

  const finalScore = corridorScore * directionMult;
  return Math.round(Math.max(0, Math.min(100, finalScore)) * 10) / 10;
}

/**
 * Distance in metres from the rider's pickup point to the nearest point
 * on the driver's route polyline.
 *
 * Used for walking-distance display in search results.
 * Previous implementation used distance to the driver's start point (home),
 * which was wildly wrong for riders near the middle of a route.
 */
export function pickupWalkMeters(
  riderFrom: Pick<GeoPoint, "lat" | "lng">,
  driverSegments: RouteSegment[],
): number {
  if (driverSegments.length === 0) return Infinity;
  return nearestOnPolyline(riderFrom, driverSegments).distM;
}

/** Rough walking time at 5 km/h. */
export function walkingMinutes(distanceM: number): number {
  return Math.ceil(distanceM / (5_000 / 60));
}
