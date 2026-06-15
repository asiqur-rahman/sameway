import 'package:sameway/core/maps/map_config.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';

/// Resolves start/end coordinates for map widgets from session + search flow.
class MapRouteResolver {
  MapRouteResolver._();

  static MapLocation get searchStart => MapLocation(
        address: FindRideFlow.instance.from.isNotEmpty
            ? FindRideFlow.instance.from
            : 'Home',
        lat: FindRideFlow.instance.fromLat ??
            AppSession.instance.currentUser?.homeLat ??
            MapConfig.defaultHome.latitude,
        lng: FindRideFlow.instance.fromLng ??
            AppSession.instance.currentUser?.homeLng ??
            MapConfig.defaultHome.longitude,
      );

  static MapLocation get searchEnd => MapLocation(
        address: FindRideFlow.instance.to.isNotEmpty
            ? FindRideFlow.instance.to
            : 'Office',
        lat: FindRideFlow.instance.toLat ??
            AppSession.instance.currentUser?.officeLat ??
            MapConfig.defaultOffice.latitude,
        lng: FindRideFlow.instance.toLng ??
            AppSession.instance.currentUser?.officeLng ??
            MapConfig.defaultOffice.longitude,
      );

  static MapLocation? postRideStart(String? address, double? lat, double? lng) {
    if (address == null || address.trim().isEmpty) return null;
    return MapLocation(
      address: address,
      lat: lat ?? AppSession.instance.currentUser?.homeLat ?? MapConfig.defaultHome.latitude,
      lng: lng ?? AppSession.instance.currentUser?.homeLng ?? MapConfig.defaultHome.longitude,
    );
  }

  static MapLocation? postRideEnd(String? address, double? lat, double? lng) {
    if (address == null || address.trim().isEmpty) return null;
    return MapLocation(
      address: address,
      lat: lat ?? AppSession.instance.currentUser?.officeLat ?? MapConfig.defaultOffice.latitude,
      lng: lng ?? AppSession.instance.currentUser?.officeLng ?? MapConfig.defaultOffice.longitude,
    );
  }
}
