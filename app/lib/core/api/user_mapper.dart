import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';

class UserMapper {
  UserMapper._();

  static UserProfile fromApi(Map<String, dynamic> json) {
    final phaseName = json['onboardingPhase'] as String? ?? 'accountCreated';
    final commuteRaw = (json['commuteType'] as String?)?.toLowerCase();
    CommuteType commuteType = CommuteType.drive;
    if (commuteRaw != null) {
      commuteType = switch (commuteRaw) {
        'ride' => CommuteType.ride,
        'walk' => CommuteType.walk,
        'both' => CommuteType.drive,
        _ => CommuteType.drive,
      };
    }

    final vehicles = json['vehicles'] as List<dynamic>? ?? [];
    VehicleInfo? vehicle;
    if (vehicles.isNotEmpty) {
      final v = vehicles.first as Map<String, dynamic>;
      vehicle = VehicleInfo(
        id: v['id'] as String?,
        type: (v['type'] as String?)?.toLowerCase() ?? 'car',
        makeModel: v['makeModel'] as String? ?? '',
        licensePlate: v['licensePlate'] as String? ?? '',
        color: v['color'] as String? ?? '',
        seats: v['availableSeats'] as int? ?? 1,
        usuallyLeave: v['usuallyLeave'] as String? ?? '',
        latestDepart: v['latestDepart'] as String? ?? '',
        riderPreference: v['riderPreference'] as String? ?? 'Anyone welcome',
      );
    }

    CommutePreferences? commutePreferences;
    final prefs = json['commutePreferences'];
    if (prefs is Map<String, dynamic>) {
      commutePreferences = CommutePreferences.fromJson(prefs);
    }

    final places = json['places'] as List<dynamic>? ?? [];
    String? homeAddress;
    String? officeAddress;
    double? officeLat;
    double? officeLng;
    double? homeLat;
    double? homeLng;
    for (final p in places) {
      final place = p as Map<String, dynamic>;
      final label = place['label'] as String?;
      if (label == 'HOME') {
        homeAddress = place['address'] as String?;
        homeLat = (place['lat'] as num?)?.toDouble();
        homeLng = (place['lng'] as num?)?.toDouble();
      } else if (label == 'OFFICE') {
        officeAddress = place['address'] as String?;
        officeLat = (place['lat'] as num?)?.toDouble();
        officeLng = (place['lng'] as num?)?.toDouble();
      }
    }

    final idVisibilityRaw = json['idVisibility'] as String?;
    final idVisibility = idVisibilityRaw == 'PUBLIC_TO_RIDERS'
        ? IdVisibility.publicToRiders
        : IdVisibility.adminOnly;

    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      workEmail: json['workEmail'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      commuteType: commuteType,
      phase: OnboardingPhase.values.byName(phaseName),
      companyName: json['companyName'] as String?,
      officeAddress: officeAddress,
      officeLat: officeLat,
      officeLng: officeLng,
      homeAddress: homeAddress,
      homeLat: homeLat,
      homeLng: homeLng,
      designation: json['designation'] as String?,
      idVisibility: idVisibility,
      vehicle: vehicle,
      commutePreferences: commutePreferences,
      workEmailVerified: json['workEmailVerified'] as bool? ?? false,
      officeLocationVerified: json['officeLocationVerified'] as bool? ?? false,
      employeeIdVerified: json['employeeIdVerified'] as bool? ?? false,
    );
  }

  static String commuteTypeToApi(CommuteType type) => switch (type) {
        CommuteType.drive => 'DRIVE',
        CommuteType.ride => 'RIDE',
        CommuteType.walk => 'WALK',
      };

  static Map<String, dynamic> vehicleToApi(VehicleInfo vehicle) => {
        'type': vehicle.type.toUpperCase() == 'BIKE' ? 'BIKE' : 'CAR',
        'makeModel': vehicle.makeModel,
        'licensePlate': vehicle.licensePlate,
        'availableSeats': vehicle.seats,
        'color': vehicle.color,
        if (vehicle.usuallyLeave.isNotEmpty) 'usuallyLeave': vehicle.usuallyLeave,
        if (vehicle.latestDepart.isNotEmpty) 'latestDepart': vehicle.latestDepart,
        if (vehicle.riderPreference.isNotEmpty) 'riderPreference': vehicle.riderPreference,
      };
}
