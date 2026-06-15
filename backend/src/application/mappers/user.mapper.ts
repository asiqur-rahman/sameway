import type { User } from "@/generated/prisma/client";

/** Onboarding phase inferred for Flutter router guards. */
export type OnboardingPhaseDto =
  | "accountCreated"
  | "profileDone"
  | "commuteDone"
  | "complete";

export function inferOnboardingPhase(
  user: User & {
    vehicles?: unknown[];
    commutePreferences?: unknown | null;
  },
): OnboardingPhaseDto {
  if (!user.commuteType) return "accountCreated";
  if (user.commuteType === "DRIVE" && (user.vehicles?.length ?? 0) === 0) {
    return "profileDone";
  }
  if (
    (user.commuteType === "RIDE" || user.commuteType === "WALK") &&
    !user.commutePreferences
  ) {
    return "profileDone";
  }
  if (!user.officeLocationVerified) return "commuteDone";
  return "complete";
}

export function toUserProfileDto(
  user: Omit<User, "passwordHash"> & {
    vehicles?: unknown[];
    places?: unknown[];
    commutePreferences?: unknown | null;
    reminderSettings?: unknown;
  },
) {
  return {
    ...user,
    onboardingPhase: inferOnboardingPhase(user as User & { vehicles?: unknown[]; commutePreferences?: unknown | null }),
    workEmailVerified: user.workEmailVerified,
    officeLocationVerified: user.officeLocationVerified,
    employeeIdVerified: user.employeeIdVerified,
  };
}
