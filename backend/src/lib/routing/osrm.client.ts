import type { GeoPoint } from "@/lib/shared";
import { env } from "@/lib/env";

/**
 * OSRM (Open Source Routing Machine) HTTP client.
 *
 * Fetches road-snapped polylines from a self-hosted OSRM instance.
 * All methods fall back gracefully to an empty result if OSRM is
 * unreachable, times out, or is not configured — the caller is
 * responsible for choosing the straight-line fallback.
 *
 * OSRM API reference: http://project-osrm.org/docs/v5.24.0/api/
 */

const REQUEST_TIMEOUT_MS = 6_000;

/** A single lat/lng point in the road polyline. */
export type PolylinePoint = { lat: number; lng: number };

type OsrmRouteResponse = {
  code: string;
  routes?: Array<{
    distance: number; // metres
    duration: number; // seconds
    geometry: {
      coordinates: [number, number][]; // [lng, lat]
    };
  }>;
};

/**
 * Fetch a road-snapped polyline from OSRM for an ordered list of waypoints.
 *
 * Uses the `/route/v1/driving` endpoint with `geometries=geojson&overview=full`
 * which returns the full resolution polyline (not simplified).
 *
 * Returns [] when:
 *   - OSRM_URL is not configured in .env
 *   - fewer than 2 waypoints provided
 *   - OSRM request times out (6 s) or returns an error
 *   - no route found (OSRM code != "Ok")
 */
export async function fetchRoadPolyline(waypoints: GeoPoint[]): Promise<PolylinePoint[]> {
  if (!env.OSRM_URL || waypoints.length < 2) return [];

  // OSRM coordinate format: lng,lat pairs separated by semicolons
  const coords = waypoints.map((p) => `${p.lng},${p.lat}`).join(";");
  const url =
    `${env.OSRM_URL}/route/v1/driving/${coords}` +
    `?geometries=geojson&overview=full&steps=false`;

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const res = await fetch(url, {
      signal: controller.signal,
      headers: { Accept: "application/json" },
    });

    if (!res.ok) {
      console.warn(`[OSRM] HTTP ${res.status} for route request — falling back to straight-line`);
      return [];
    }

    const data = (await res.json()) as OsrmRouteResponse;

    if (data.code !== "Ok" || !data.routes?.[0]) {
      console.warn(`[OSRM] No route found (code: ${data.code}) — falling back to straight-line`);
      return [];
    }

    // Convert [lng, lat] → { lat, lng }
    return data.routes[0].geometry.coordinates.map(([lng, lat]) => ({ lat, lng }));
  } catch (err) {
    const reason = err instanceof Error ? err.message : String(err);
    console.warn(`[OSRM] Request failed (${reason}) — falling back to straight-line`);
    return [];
  } finally {
    clearTimeout(timer);
  }
}

/**
 * Convert an ordered list of polyline points into RouteSegment pairs.
 * Each consecutive pair of points becomes one segment.
 *
 * A 40-point polyline → 39 segments, all representing real road geometry.
 */
export function polylineToSegments(points: PolylinePoint[]): Array<{
  start: GeoPoint;
  end: GeoPoint;
}> {
  const segments: Array<{ start: GeoPoint; end: GeoPoint }> = [];
  for (let i = 0; i < points.length - 1; i++) {
    segments.push({
      start: { address: "", lat: points[i].lat,     lng: points[i].lng },
      end:   { address: "", lat: points[i + 1].lat, lng: points[i + 1].lng },
    });
  }
  return segments;
}

/**
 * Fetch OSRM road polyline and convert to segments.
 * Falls back to an empty array if OSRM is unavailable.
 */
export async function fetchRoadSegments(waypoints: GeoPoint[]): Promise<Array<{
  start: GeoPoint;
  end: GeoPoint;
}>> {
  const points = await fetchRoadPolyline(waypoints);
  if (points.length < 2) return [];
  return polylineToSegments(points);
}
