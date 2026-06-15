import type { Prisma, Ride, User, Vehicle } from "@/generated/prisma/client";

export type RideWithDriver = Ride & {
  vehicle: Vehicle;
  driver: Pick<User, "id" | "fullName" | "photoUrl" | "rating" | "gender" | "companyDomain" | "rideCount" | "verificationStatus">;
};

export type SearchCandidateFilter = {
  where: Prisma.RideWhereInput;
  take: number;
};

export interface IRideRepository {
  findSearchCandidates(filter: SearchCandidateFilter): Promise<RideWithDriver[]>;
  findById(id: string): Promise<RideWithDriver | null>;
  findByIdForDriver(id: string, driverId: string): Promise<Ride | null>;
  create(data: Prisma.RideCreateInput): Promise<Ride>;
  updateStatus(id: string, status: Ride["status"]): Promise<Ride>;
  listByDriver(driverId: string, take?: number): Promise<Ride[]>;
}
