/// A location picked on the map (office, home, ride stop, etc.).
class MapLocation {
  const MapLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  bool get isValid => address.trim().isNotEmpty && (lat != 0 || lng != 0);
}

/// Preset office pins for the map picker prototype (Dhaka area).
class OfficeMapPresets {
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
