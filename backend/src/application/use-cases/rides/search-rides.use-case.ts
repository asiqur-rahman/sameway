import type { Prisma } from "@/generated/prisma/client";
import { toRideListingDto } from "@/application/mappers/ride.mapper";
import type { IRideRepository } from "@/domain/repositories/ride.repository";
import type { ICacheStore } from "@/domain/ports/cache.port";
import { db } from "@/lib/db";
import { env } from "@/lib/env";
import { paginate } from "@/lib/shared";
import {
  expandSearchBBox,
  searchCacheKey,
  segmentOverlapsBBox,
} from "@/modules/matching/geo";
import {
  scoreRouteMatch,
  walkingMinutes,
  type RouteSegment,
} from "@/modules/matching/matching.service";
import type { searchRidesSchema } from "@/modules/rides/rides.schema";
import type { z } from "zod";

export type SearchRidesInput = z.infer<typeof searchRidesSchema>;

export type SearchRidesResult = {
  items: ReturnType<typeof toRideListingDto>[];
  total: number;
  page: number;
  limit: number;
};

function buildGeoWhere(
  bbox: ReturnType<typeof expandSearchBBox>,
): Prisma.RideWhereInput {
  return {
    OR: [
      {
        AND: [
          { startLat: { gte: bbox.minLat, lte: bbox.maxLat } },
          { startLng: { gte: bbox.minLng, lte: bbox.maxLng } },
        ],
      },
      {
        AND: [
          { endLat: { gte: bbox.minLat, lte: bbox.maxLat } },
          { endLng: { gte: bbox.minLng, lte: bbox.maxLng } },
        ],
      },
      {
        AND: [
          { startLat: { lte: bbox.maxLat } },
          { endLat: { gte: bbox.minLat } },
          { startLng: { lte: bbox.maxLng } },
          { endLng: { gte: bbox.minLng } },
        ],
      },
    ],
  };
}

export const SEARCH_CACHE_PREFIX = "search:";

export class SearchRidesUseCase {
  constructor(
    private readonly rides: IRideRepository,
    private readonly cache: ICacheStore,
  ) {}

  async execute(userId: string, input: SearchRidesInput): Promise<SearchRidesResult> {
    const { page, limit, fromLat, fromLng, toLat, toLng, vehicleFilter } = input;
    const cacheKey = `${SEARCH_CACHE_PREFIX}${userId}:${searchCacheKey(input)}`;

    if (env.SEARCH_CACHE_TTL_SEC > 0) {
      const cached = await this.cache.get<SearchRidesResult>(cacheKey);
      if (cached) return cached;
    }

    const bbox = expandSearchBBox(fromLat, fromLng, toLat, toLng, env.SEARCH_BBOX_BUFFER_KM);
    const rider = await db.user.findUnique({ where: { id: userId }, select: { gender: true } });

    const where: Prisma.RideWhereInput = {
      status: "OPEN",
      departureAt: { gte: new Date() },
      driverId: { not: userId },
      AND: [buildGeoWhere(bbox)],
      ...(vehicleFilter !== "ANY" ? { vehicle: { type: vehicleFilter } } : {}),
    };

    const candidates = await this.rides.findSearchCandidates({
      where,
      take: env.SEARCH_CANDIDATE_CAP,
    });

    const riderFrom = { address: input.fromAddress ?? "", lat: fromLat, lng: fromLng };
    const riderTo = { address: input.toAddress ?? "", lat: toLat, lng: toLng };

    const scored = candidates
      .filter((ride) =>
        segmentOverlapsBBox(ride.startLat, ride.startLng, ride.endLat, ride.endLng, bbox),
      )
      .map((ride) => {
        const segments = (ride.segments as unknown as RouteSegment[]) ?? [];
        const matchScore = scoreRouteMatch({ riderFrom, riderTo, driverSegments: segments });
        const walkMin = walkingMinutes(
          Math.hypot(fromLat - ride.startLat, fromLng - ride.startLng) * 111_000,
        );
        return { ...ride, matchScore, walkMin };
      })
      .filter((r) => {
        if (r.matchScore < input.minMatchScore) return false;
        if (r.walkMin > input.maxWalkingMinutes) return false;
        if (input.genderPreference === "SAME" && rider?.gender && r.driver.gender) {
          return r.driver.gender === rider.gender;
        }
        return r.matchScore > 0;
      })
      .sort((a, b) => b.matchScore - a.matchScore)
      .map(toRideListingDto);

    const { skip, take } = paginate(page, limit);
    const result: SearchRidesResult = {
      items: scored.slice(skip, skip + take),
      total: scored.length,
      page,
      limit,
    };

    if (env.SEARCH_CACHE_TTL_SEC > 0) {
      await this.cache.set(cacheKey, result, env.SEARCH_CACHE_TTL_SEC * 1000);
    }

    return result;
  }

  /** Invalidate only ride-search entries (keeps geocode cache warm at scale). */
  async invalidateCache(): Promise<void> {
    await this.cache.deleteByPrefix(SEARCH_CACHE_PREFIX);
  }
}
