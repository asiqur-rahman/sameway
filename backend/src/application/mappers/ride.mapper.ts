import type { RideWithDriver } from "@/domain/repositories/ride.repository";
import type { RouteSegment } from "@/modules/matching/matching.service";

/** Stable API shape aligned with Flutter `FindRideListing`. */
export type RideListingDto = {
  id: string;
  driverName: string;
  driverFullName: string;
  driverInitial: string;
  company: string;
  from: string;
  to: string;
  departTime: string;
  arriveTime: string;
  seats: number;
  overlap: number;
  rides: number;
  onTimePct: number;
  vehicleLabel: string;
  vehicleDetail: string;
  pickupLabel: string;
  pickupDetail: string;
  driverNote: string;
  isBike: boolean;
  coRiderName: string | null;
  coRiderInitial: string | null;
  kudos: string[];
  matchScore: number;
  walkMinutes: number;
};

function shortName(fullName: string): string {
  const parts = fullName.trim().split(/\s+/);
  if (parts.length < 2) return fullName;
  return `${parts[0]} ${parts[1][0]}.`;
}

function shortPlace(address: string): string {
  return address.split(",")[0]?.trim() ?? address;
}

function formatTime(date: Date): string {
  const h = date.getHours();
  const m = date.getMinutes().toString().padStart(2, "0");
  const period = h >= 12 ? "PM" : "AM";
  const hour12 = h % 12 === 0 ? 12 : h % 12;
  return `${hour12}:${m} ${period}`;
}

export function toRideListingDto(
  ride: RideWithDriver & { matchScore: number; walkMin: number },
): RideListingDto {
  const isBike = ride.vehicle.type === "BIKE";
  const vehicleEmoji = isBike ? "🏍" : "🚗";
  const initial = ride.driver.fullName.trim()[0]?.toUpperCase() ?? "?";

  return {
    id: ride.id,
    driverName: shortName(ride.driver.fullName),
    driverFullName: ride.driver.fullName,
    driverInitial: initial,
    company: ride.driver.companyDomain ?? "Verified commuter",
    from: shortPlace(ride.startAddress),
    to: shortPlace(ride.endAddress),
    departTime: formatTime(ride.departureAt),
    arriveTime: `~${formatTime(new Date(ride.departureAt.getTime() + 50 * 60_000))}`,
    seats: ride.availableSeats,
    overlap: Math.round(ride.matchScore),
    rides: ride.driver.rideCount,
    onTimePct: Math.min(99, 85 + Math.round(ride.driver.rating * 3)),
    vehicleLabel: `${vehicleEmoji} ${ride.vehicle.makeModel}`,
    vehicleDetail: `${ride.vehicle.color ?? "—"} · ${ride.vehicle.availableSeats + 1} seats`,
    pickupLabel: `Your pickup (${ride.walkMin} min walk)`,
    pickupDetail: shortPlace(ride.startAddress),
    driverNote: '"Coordinate pickup and cost split directly."',
    isBike,
    coRiderName: null,
    coRiderInitial: null,
    kudos: ["🚗 Smooth driver", "⏰ Punctual", "💬 Good chat"],
    matchScore: ride.matchScore,
    walkMinutes: ride.walkMin,
  };
}

export function toRideDetailDto(ride: RideWithDriver) {
  const segments = (ride.segments as unknown as RouteSegment[]) ?? [];
  return {
    id: ride.id,
    route: `${ride.startAddress} → ${ride.endAddress}`,
    start: { address: ride.startAddress, lat: ride.startLat, lng: ride.startLng },
    end: { address: ride.endAddress, lat: ride.endLat, lng: ride.endLng },
    stops: ride.stops,
    segments,
    departureAt: ride.departureAt,
    repeat: ride.repeat,
    availableSeats: ride.availableSeats,
    status: ride.status,
    driver: {
      id: ride.driver.id,
      name: ride.driver.fullName,
      photoUrl: ride.driver.photoUrl,
      rating: ride.driver.rating,
      rideCount: ride.driver.rideCount,
      verified: ride.driver.verificationStatus === "VERIFIED",
    },
    vehicle: ride.vehicle,
  };
}

export type BookingRideDto = {
  id: string;
  route: string;
  from: string;
  to: string;
  timeLabel: string;
  detail: string;
  status: string;
  driverName: string | null;
  isDriver: boolean;
  chatThreadId: string | null;
};

export function toDriverBookingDto(ride: {
  id: string;
  startAddress: string;
  endAddress: string;
  departureAt: Date;
  availableSeats: number;
  repeat: string;
  status: string;
}): BookingRideDto {
  return {
    id: ride.id,
    route: `${ride.startAddress} → ${ride.endAddress}`,
    from: ride.startAddress,
    to: ride.endAddress,
    timeLabel: formatTime(ride.departureAt),
    detail: `${ride.availableSeats} seats · ${ride.repeat}`,
    status: ride.status.toLowerCase(),
    driverName: null,
    isDriver: true,
    chatThreadId: null,
  };
}
