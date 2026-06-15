/// Holds onboarding choices across the sign-up flow (UI prototype state).
class OnboardingState {
  OnboardingState._();

  static final instance = OnboardingState._();

  CommuteType commuteType = CommuteType.drive;

  /// Set when a driver finishes step 2 or a rider adds a vehicle from home.
  bool hasVehicleDetails = false;

  /// Optional job title from work verification (step 3).
  String? designation;

  bool get isDriver => commuteType == CommuteType.drive;
  bool get isRider => commuteType == CommuteType.ride;
  bool get isWalker => commuteType == CommuteType.walk;

  /// Drivers land on Offer; riders and walkers land on Find.
  int get defaultHomeTab => isDriver ? 0 : 1;

  void reset() {
    commuteType = CommuteType.drive;
    hasVehicleDetails = false;
    designation = null;
  }
}

enum CommuteType { drive, ride, walk }
