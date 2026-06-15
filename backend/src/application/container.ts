import { MemoryCacheStore } from "@/infrastructure/cache/memory-cache.store";
import { PrismaRideRepository } from "@/infrastructure/persistence/prisma-ride.repository";
import { SearchRidesUseCase } from "@/application/use-cases/rides/search-rides.use-case";
import {
  CancelRideUseCase,
  UpdateRideStatusUseCase,
} from "@/application/use-cases/rides/ride-lifecycle.use-case";

const rideRepository = new PrismaRideRepository();
const cacheStore = new MemoryCacheStore();

export const container = {
  rideRepository,
  cacheStore,
  searchRides: new SearchRidesUseCase(rideRepository, cacheStore),
  cancelRide: new CancelRideUseCase(rideRepository),
  updateRideStatus: new UpdateRideStatusUseCase(rideRepository),
};
