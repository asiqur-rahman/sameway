import 'dart:convert';

import 'package:sameway/features/onboarding/onboarding_state.dart';

enum OnboardingPhase {
  accountCreated,
  profileDone,
  commuteDone,
  complete,
}

enum IdVisibility { adminOnly, publicToRiders }

class VehicleInfo {
  const VehicleInfo({
    this.id,
    required this.type,
    required this.makeModel,
    required this.licensePlate,
    required this.color,
    required this.seats,
    this.usuallyLeave = '',
    this.latestDepart = '',
    this.riderPreference = 'Anyone welcome',
  });

  final String? id;
  final String type;
  final String makeModel;
  final String licensePlate;
  final String color;
  final int seats;
  final String usuallyLeave;
  final String latestDepart;
  final String riderPreference;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type,
        'makeModel': makeModel,
        'licensePlate': licensePlate,
        'color': color,
        'seats': seats,
        'usuallyLeave': usuallyLeave,
        'latestDepart': latestDepart,
        'riderPreference': riderPreference,
      };

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => VehicleInfo(
        id: json['id'] as String?,
        type: json['type'] as String? ?? 'car',
        makeModel: json['makeModel'] as String? ?? '',
        licensePlate: json['licensePlate'] as String? ?? '',
        color: json['color'] as String? ?? '',
        seats: json['seats'] as int? ?? 1,
        usuallyLeave: json['usuallyLeave'] as String? ?? '',
        latestDepart: json['latestDepart'] as String? ?? '',
        riderPreference: json['riderPreference'] as String? ?? 'Anyone welcome',
      );
}

class CommutePreferences {
  const CommutePreferences({
    this.preferredVehicle = 'Any',
    this.genderPreference = 'No preference',
    this.maxWalkMinutes = 10,
    this.leaveBy = '',
    this.arriveBy = '',
    this.walkWithOthers = true,
    this.walkingPace = 'Normal',
  });

  final String preferredVehicle;
  final String genderPreference;
  final int maxWalkMinutes;
  final String leaveBy;
  final String arriveBy;
  final bool walkWithOthers;
  final String walkingPace;

  Map<String, dynamic> toJson() => {
        'preferredVehicle': preferredVehicle,
        'genderPreference': genderPreference,
        'maxWalkMinutes': maxWalkMinutes,
        'leaveBy': leaveBy,
        'arriveBy': arriveBy,
        'walkWithOthers': walkWithOthers,
        'walkingPace': walkingPace,
      };

  factory CommutePreferences.fromJson(Map<String, dynamic> json) =>
      CommutePreferences(
        preferredVehicle: json['preferredVehicle'] as String? ?? 'Any',
        genderPreference: json['genderPreference'] as String? ?? 'No preference',
        maxWalkMinutes: json['maxWalkMinutes'] as int? ?? 10,
        leaveBy: json['leaveBy'] as String? ?? '',
        arriveBy: json['arriveBy'] as String? ?? '',
        walkWithOthers: json['walkWithOthers'] as bool? ?? true,
        walkingPace: json['walkingPace'] as String? ?? 'Normal',
      );
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.fullName,
    required this.workEmail,
    required this.phone,
    this.photoUrl,
    this.commuteType = CommuteType.drive,
    this.phase = OnboardingPhase.accountCreated,
    this.companyName,
    this.officeAddress,
    this.officeLat,
    this.officeLng,
    this.homeAddress,
    this.homeLat,
    this.homeLng,
    this.designation,
    this.idVisibility = IdVisibility.adminOnly,
    this.idCardPath,
    this.vehicle,
    this.commutePreferences,
    this.workEmailVerified = false,
    this.officeLocationVerified = false,
    this.employeeIdVerified = false,
  });

  final String id;
  String fullName;
  String workEmail;
  String phone;
  String? photoUrl;
  CommuteType commuteType;
  OnboardingPhase phase;
  String? companyName;
  String? officeAddress;
  double? officeLat;
  double? officeLng;
  String? homeAddress;
  double? homeLat;
  double? homeLng;
  String? designation;
  IdVisibility idVisibility;
  String? idCardPath;
  VehicleInfo? vehicle;
  CommutePreferences? commutePreferences;
  bool workEmailVerified;
  bool officeLocationVerified;
  bool employeeIdVerified;

  String get firstName => fullName.split(' ').first;

  bool get onboardingComplete => phase == OnboardingPhase.complete;

  bool get hasVehicleDetails =>
      vehicle != null && vehicle!.makeModel.trim().isNotEmpty;

  int get defaultHomeTab => commuteType == CommuteType.drive ? 0 : 1;

  bool get isDriver => commuteType == CommuteType.drive;
  bool get isRider => commuteType == CommuteType.ride;
  bool get isWalker => commuteType == CommuteType.walk;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'workEmail': workEmail,
        'phone': phone,
        'photoUrl': photoUrl,
        'commuteType': commuteType.name,
        'phase': phase.name,
        'companyName': companyName,
        'officeAddress': officeAddress,
        'officeLat': officeLat,
        'officeLng': officeLng,
        'homeAddress': homeAddress,
        'homeLat': homeLat,
        'homeLng': homeLng,
        'designation': designation,
        'idVisibility': idVisibility.name,
        'idCardPath': idCardPath,
        'vehicle': vehicle?.toJson(),
        'commutePreferences': commutePreferences?.toJson(),
        'workEmailVerified': workEmailVerified,
        'officeLocationVerified': officeLocationVerified,
        'employeeIdVerified': employeeIdVerified,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        workEmail: json['workEmail'] as String,
        phone: json['phone'] as String,
        photoUrl: json['photoUrl'] as String?,
        commuteType: CommuteType.values.byName(
          json['commuteType'] as String? ?? 'drive',
        ),
        phase: OnboardingPhase.values.byName(
          json['phase'] as String? ?? 'accountCreated',
        ),
        companyName: json['companyName'] as String?,
        officeAddress: json['officeAddress'] as String?,
        officeLat: (json['officeLat'] as num?)?.toDouble(),
        officeLng: (json['officeLng'] as num?)?.toDouble(),
        homeAddress: json['homeAddress'] as String?,
        homeLat: (json['homeLat'] as num?)?.toDouble(),
        homeLng: (json['homeLng'] as num?)?.toDouble(),
        designation: json['designation'] as String?,
        idVisibility: IdVisibility.values.byName(
          json['idVisibility'] as String? ?? 'adminOnly',
        ),
        idCardPath: json['idCardPath'] as String?,
        vehicle: json['vehicle'] != null
            ? VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>)
            : null,
        commutePreferences: json['commutePreferences'] != null
            ? CommutePreferences.fromJson(
                json['commutePreferences'] as Map<String, dynamic>,
              )
            : null,
        workEmailVerified: json['workEmailVerified'] as bool? ?? false,
        officeLocationVerified: json['officeLocationVerified'] as bool? ?? false,
        employeeIdVerified: json['employeeIdVerified'] as bool? ?? false,
      );

  static String encodeList(List<UserProfile> users) =>
      jsonEncode(users.map((u) => u.toJson()).toList());

  static List<UserProfile> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
