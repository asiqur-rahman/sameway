import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:sameway/core/maps/map_config.dart';

/// Smooth positions along a polyline for live marker animation.
class RouteInterpolator {
  RouteInterpolator(List<LatLng> points, {int segmentsPerLeg = 24}) {
    _samples = _densify(points, segmentsPerLeg);
  }

  late final List<LatLng> _samples;

  LatLng positionAt(double t) {
    if (_samples.isEmpty) return MapConfig.defaultCenter;
    if (_samples.length == 1) return _samples.first;
    final clamped = t.clamp(0.0, 1.0);
    final index = clamped * (_samples.length - 1);
    final i = index.floor();
    final frac = index - i;
    if (i >= _samples.length - 1) return _samples.last;
    return _lerp(_samples[i], _samples[i + 1], frac);
  }

  static List<LatLng> _densify(List<LatLng> points, int segmentsPerLeg) {
    if (points.length < 2) return List<LatLng>.from(points);
    final out = <LatLng>[];
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      for (var s = 0; s < segmentsPerLeg; s++) {
        final t = s / segmentsPerLeg;
        out.add(_lerp(a, b, t));
      }
    }
    out.add(points.last);
    return out;
  }

  static LatLng _lerp(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  static double distanceKm(LatLng a, LatLng b) {
    const earthRadius = 6371.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final lat1 = _toRad(a.latitude);
    final lat2 = _toRad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * earthRadius * math.asin(math.sqrt(h));
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
