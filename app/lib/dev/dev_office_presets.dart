import 'package:sameway/core/models/map_location.dart';

/// Offline / catalog-only office suggestions — not used when [EnvConfig.apiEnabled].
abstract final class DevOfficePresets {
  static const List<MapLocation> offices = [
    MapLocation(
      address: 'Grameenphone House, Bashundhara, Dhaka',
      lat: 23.8103,
      lng: 90.4254,
    ),
    MapLocation(
      address: 'Banglalink HQ, Tiger\'s Den, Gulshan, Dhaka',
      lat: 23.7808,
      lng: 90.4168,
    ),
    MapLocation(
      address: 'BRAC Centre, Mohakhali, Dhaka',
      lat: 23.7805,
      lng: 90.4042,
    ),
    MapLocation(
      address: 'Motijheel Commercial Area, Dhaka',
      lat: 23.7331,
      lng: 90.4172,
    ),
  ];
}
