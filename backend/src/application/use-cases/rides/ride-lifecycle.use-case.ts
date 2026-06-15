import type { IRideRepository } from "@/domain/repositories/ride.repository";
import { NotFoundError, ForbiddenError } from "@/lib/http/errors";
import type { RideStatus } from "@/generated/prisma/client";

export class CancelRideUseCase {
  constructor(private readonly rides: IRideRepository) {}

  async execute(rideId: string, driverId: string) {
    const ride = await this.rides.findByIdForDriver(rideId, driverId);
    if (!ride) throw new NotFoundError("Ride");
    if (ride.status === "COMPLETED" || ride.status === "CANCELLED") {
      throw new ForbiddenError("Ride cannot be cancelled");
    }
    return this.rides.updateStatus(rideId, "CANCELLED");
  }
}

const allowedTransitions: Record<string, RideStatus[]> = {
  OPEN: ["IN_PROGRESS", "CANCELLED", "FULL"],
  FULL: ["IN_PROGRESS", "CANCELLED"],
  IN_PROGRESS: ["COMPLETED", "CANCELLED"],
};

export class UpdateRideStatusUseCase {
  constructor(private readonly rides: IRideRepository) {}

  async execute(rideId: string, driverId: string, nextStatus: RideStatus) {
    const ride = await this.rides.findByIdForDriver(rideId, driverId);
    if (!ride) throw new NotFoundError("Ride");
    const allowed = allowedTransitions[ride.status] ?? [];
    if (!allowed.includes(nextStatus)) {
      throw new ForbiddenError(`Cannot transition from ${ride.status} to ${nextStatus}`);
    }
    return this.rides.updateStatus(rideId, nextStatus);
  }
}
