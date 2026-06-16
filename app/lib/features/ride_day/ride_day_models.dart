import 'package:intl/intl.dart';

class LiveParticipant {
  const LiveParticipant({
    required this.userId,
    required this.name,
    required this.role,
    required this.status,
    this.photoUrl,
  });

  final String userId;
  final String name;
  final String role;
  final String status;
  final String? photoUrl;

  factory LiveParticipant.fromJson(Map<String, dynamic> json) {
    return LiveParticipant(
      userId: json['userId'] as String,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'RIDER',
      status: json['status'] as String? ?? 'CONFIRMED',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  String get statusLabel {
    return switch (status) {
      'HEADING_OUT' => 'Heading out',
      'AT_PICKUP' => 'At pickup',
      'ON_WAY' => 'On the way',
      'LATE' => 'Running late',
      'CANCELLED' => 'Cancelled',
      _ => 'Confirmed',
    };
  }
}

class LiveRide {
  const LiveRide({
    required this.id,
    required this.status,
    required this.route,
    required this.from,
    required this.to,
    required this.departureAt,
    required this.minutesUntilDeparture,
    required this.isDriver,
    required this.participants,
    required this.riders,
    this.driver,
    required this.vehicleLabel,
  });

  final String id;
  final String status;
  final String route;
  final String from;
  final String to;
  final DateTime departureAt;
  final int minutesUntilDeparture;
  final bool isDriver;
  final LiveParticipant? driver;
  final List<LiveParticipant> riders;
  final List<LiveParticipant> participants;
  final String vehicleLabel;

  factory LiveRide.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>? ?? [])
        .map((e) => LiveParticipant.fromJson(e as Map<String, dynamic>))
        .toList();
    final riders = (json['riders'] as List<dynamic>? ?? [])
        .map((e) => LiveParticipant.fromJson(e as Map<String, dynamic>))
        .toList();
    final driverJson = json['driver'] as Map<String, dynamic>?;

    return LiveRide(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'OPEN',
      route: json['route'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      departureAt: DateTime.parse(json['departureAt'] as String),
      minutesUntilDeparture: json['minutesUntilDeparture'] as int? ?? 0,
      isDriver: json['isDriver'] as bool? ?? false,
      driver: driverJson != null ? LiveParticipant.fromJson(driverJson) : null,
      riders: riders.isNotEmpty ? riders : participants.where((p) => p.role == 'RIDER').toList(),
      participants: participants,
      vehicleLabel: json['vehicleLabel'] as String? ?? '',
    );
  }

  String get departureTimeLabel => DateFormat.jm().format(departureAt.toLocal());
}

class TodayRideSummary {
  const TodayRideSummary({
    required this.rideId,
    required this.role,
    required this.route,
    required this.departureAt,
    required this.minutesUntilDeparture,
    required this.riderCount,
    required this.status,
  });

  final String rideId;
  final String role;
  final String route;
  final DateTime departureAt;
  final int minutesUntilDeparture;
  final int riderCount;
  final String status;

  bool get isDriver => role == 'DRIVER';

  factory TodayRideSummary.fromJson(Map<String, dynamic> json) {
    return TodayRideSummary(
      rideId: json['rideId'] as String,
      role: json['role'] as String? ?? 'RIDER',
      route: json['route'] as String? ?? '',
      departureAt: DateTime.parse(json['departureAt'] as String),
      minutesUntilDeparture: json['minutesUntilDeparture'] as int? ?? 0,
      riderCount: json['riderCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'OPEN',
    );
  }

  String get departureTimeLabel => DateFormat.jm().format(departureAt.toLocal());
}
