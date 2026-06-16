import 'package:latlong2/latlong.dart';
import 'package:sameway/core/models/map_location.dart';

extension MapLocationLatLng on MapLocation {
  LatLng toLatLng() => LatLng(lat, lng);

  static MapLocation fromLatLng(LatLng pos, {String address = ''}) {
    return MapLocation(address: address, lat: pos.latitude, lng: pos.longitude);
  }
}
