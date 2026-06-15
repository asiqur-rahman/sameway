import type { Prisma } from "@/generated/prisma/client";
import { db } from "@/lib/db";
import type { IRideRepository, RideWithDriver, SearchCandidateFilter } from "@/domain/repositories/ride.repository";

const driverSelect = {
  id: true,
  fullName: true,
  photoUrl: true,
  rating: true,
  gender: true,
  companyDomain: true,
  rideCount: true,
  verificationStatus: true,
} as const;

export class PrismaRideRepository implements IRideRepository {
  async findSearchCandidates({ where, take }: SearchCandidateFilter): Promise<RideWithDriver[]> {
    return db.ride.findMany({
      where,
      include: { vehicle: true, driver: { select: driverSelect } },
      orderBy: { departureAt: "asc" },
      take,
    }) as Promise<RideWithDriver[]>;
  }

  async findById(id: string): Promise<RideWithDriver | null> {
    return db.ride.findUnique({
      where: { id },
      include: { vehicle: true, driver: { select: driverSelect } },
    }) as Promise<RideWithDriver | null>;
  }

  async findByIdForDriver(id: string, driverId: string) {
    return db.ride.findFirst({ where: { id, driverId } });
  }

  async create(data: Prisma.RideCreateInput) {
    return db.ride.create({ data });
  }

  async updateStatus(id: string, status: RideWithDriver["status"]) {
    return db.ride.update({ where: { id }, data: { status } });
  }

  async listByDriver(driverId: string, take = 100) {
    return db.ride.findMany({
      where: { driverId },
      orderBy: { departureAt: "desc" },
      take,
    });
  }
}
