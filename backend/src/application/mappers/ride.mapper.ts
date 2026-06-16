import type { RideWithDriver } from "@/domain/repositories/ride.repository";
import { distanceMeters } from "@/modules/matching/matching.service";
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
  /** Straight-line route distance in kilometres (start → end). */
  distanceKm: number;
  /**
   * Suggested fair-share cost in Bangladeshi Taka.
   * Formula: distanceKm × 15 BDT/km, rounded up to the nearest 5 BDT.
   * Reflects petrol cost only — a fair split between driver and rider.
   * Displayed as a guide; actual amount is agreed between both parties.
   */
  suggestedFareBDT: number;
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

/** Round n up to the nearest multiple of step. */
function roundUpTo(n: number, step: number): number {
  return Math.ceil(n / step) * step;
}

export function toRideListingDto(
  ride: RideWithDriver & { matchScore: number; walkMin: number },
): RideListingDto {
  const isBike = ride.vehicle.type === "BIKE";
  const vehicleEmoji = isBike ? "🏍" : "🚗";
  const initial = ride.driver.fullName.trim()[0]?.toUpperCase() ?? "?";

  const distanceKm =
    distanceMeters(
      { lat: ride.startLat, lng: ride.startLng },
      { lat: ride.endLat, lng: ride.endLng },
    ) / 1_000;

  // 15 BDT/km covers petrol cost only — a fair rider share for Dhaka distances.
  // Rounded up to nearest 5 BDT so the amount feels like a natural conversation starter.
  const suggestedFareBDT = roundUpTo(Math.max(10, Math.round(distanceKm * 15)), 5);

  const fareNote = `Suggested share: ৳${suggestedFareBDT} (${Math.round(distanceKm)} km · fuel only)`;

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
    driverNote: fareNote,
    isBike,
    coRiderName: null,
    coRiderInitial: null,
    kudos: ["🚗 Smooth driver", "⏰ Punctual", "💬 Good chat"],
    matchScore: ride.matchScore,
    walkMinutes: ride.walkMin,
    distanceKm: Math.round(distanceKm * 10) / 10,
    suggestedFareBDT,
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

export type LiveParticipantDto = {
  userId: string;
  name: string;
  photoUrl: string | null;
  role: "DRIVER" | "RIDER";
  status: string;
};

export type LiveRideDto = {
  id: string;
  status: string;
  route: string;
  from: string;
  to: string;
  departureAt: string;
  minutesUntilDeparture: number;
  isDriver: boolean;
  driver: LiveParticipantDto | null;
  riders: LiveParticipantDto[];
  participants: LiveParticipantDto[];
  vehicleLabel: string;
};

export function toLiveRideDto(
  ride: RideWithDriver & {
    participants: Array<{
      userId: string;
      role: string;
      status: string;
      user: { id: string; fullName: string; photoUrl: string | null };
    }>;
  },
  viewerUserId: string,
): LiveRideDto {
  const participants: LiveParticipantDto[] = ride.participants.map((p) => ({
    userId: p.userId,
    name: p.user.fullName,
    photoUrl: p.user.photoUrl,
    role: p.role as "DRIVER" | "RIDER",
    status: p.status,
  }));

  const driver = participants.find((p) => p.role === "DRIVER") ?? null;
  const riders = participants.filter((p) => p.role === "RIDER");
  const isDriver = driver?.userId === viewerUserId;
  const isBike = ride.vehicle.type === "BIKE";
  const vehicleEmoji = isBike ? "🏍" : "🚗";

  const msUntil = ride.departureAt.getTime() - Date.now();
  const minutesUntilDeparture = Math.max(0, Math.round(msUntil / 60_000));

  return {
    id: ride.id,
    status: ride.status,
    route: `${ride.startAddress} → ${ride.endAddress}`,
    from: ride.startAddress,
    to: ride.endAddress,
    departureAt: ride.departureAt.toISOString(),
    minutesUntilDeparture,
    isDriver,
    driver,
    riders,
    participants,
    vehicleLabel: `${vehicleEmoji} ${ride.vehicle.makeModel}`,
  };
}

export type TodayRideSummaryDto = {
  rideId: string;
  role: "DRIVER" | "RIDER";
  route: string;
  departureAt: string;
  minutesUntilDeparture: number;
  riderCount: number;
  status: string;
};

export function toTodayRideSummary(
  ride: RideWithDriver & {
    participants: Array<{ userId: string; role: string; status: string }>;
  },
  viewerUserId: string,
): TodayRideSummaryDto {
  const myPart = ride.participants.find((p) => p.userId === viewerUserId);
  const role = (myPart?.role ?? "RIDER") as "DRIVER" | "RIDER";
  const riders = ride.participants.filter((p) => p.role === "RIDER");
  const msUntil = ride.departureAt.getTime() - Date.now();

  return {
    rideId: ride.id,
    role,
    route: `${shortPlace(ride.startAddress)} → ${shortPlace(ride.endAddress)}`,
    departureAt: ride.departureAt.toISOString(),
    minutesUntilDeparture: Math.max(0, Math.round(msUntil / 60_000)),
    riderCount: riders.length,
    status: ride.status,
  };
}

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
