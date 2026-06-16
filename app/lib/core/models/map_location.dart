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
