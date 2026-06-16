/// A commute endpoint with verified coordinates for ride search.
class SearchLocation {
  const SearchLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  bool get isValid =>
      address.trim().isNotEmpty && (lat != 0 || lng != 0) && lat.abs() <= 90 && lng.abs() <= 180;

  SearchLocation copyWith({String? address, double? lat, double? lng}) => SearchLocation(
        address: address ?? this.address,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );
}
