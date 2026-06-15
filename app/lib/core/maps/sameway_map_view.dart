import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/maps/map_config.dart';
import 'package:sameway/core/maps/map_location_latlng.dart';
import 'package:sameway/core/maps/route_interpolator.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

/// Native Google Map with optional route polyline and live moving markers.
class SamewayMapView extends StatefulWidget {
  const SamewayMapView({
    super.key,
    required this.height,
    this.start,
    this.end,
    this.stops = const [],
    this.initialCenter,
    this.pickerMode = false,
    this.liveMarkers = false,
    this.showMyLocation = false,
    this.zoom,
    this.hint,
    this.borderRadius,
    this.onPickerChanged,
    this.pickerAddress,
  });

  final double height;
  final MapLocation? start;
  final MapLocation? end;
  final List<MapLocation> stops;
  final MapLocation? initialCenter;
  final bool pickerMode;
  final bool liveMarkers;
  final bool showMyLocation;
  final double? zoom;
  final String? hint;
  final double? borderRadius;
  final ValueChanged<MapLocation>? onPickerChanged;
  final String? pickerAddress;

  @override
  State<SamewayMapView> createState() => _SamewayMapViewState();
}

class _SamewayMapViewState extends State<SamewayMapView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  LatLng? _pickerPosition;
  LatLng? _liveDriverPosition;
  AnimationController? _liveAnim;
  RouteInterpolator? _interpolator;
  bool _mapReady = false;

  List<LatLng> get _routePoints {
    final points = <LatLng>[];
    final start = widget.start;
    final end = widget.end;
    if (start != null && start.isValid) points.add(start.toLatLng());
    for (final stop in widget.stops) {
      if (stop.isValid) points.add(stop.toLatLng());
    }
    if (end != null && end.isValid) points.add(end.toLatLng());
    if (points.length >= 2) return points;
    return [MapConfig.defaultHome, MapConfig.defaultOffice];
  }

  LatLng get _initialTarget {
    if (widget.pickerMode) {
      return _pickerPosition ??
          widget.initialCenter?.toLatLng() ??
          widget.start?.toLatLng() ??
          MapConfig.defaultCenter;
    }
    final route = _routePoints;
    if (route.isNotEmpty) {
      return LatLng(
        (route.first.latitude + route.last.latitude) / 2,
        (route.first.longitude + route.last.longitude) / 2,
      );
    }
    return MapConfig.defaultCenter;
  }

  @override
  void initState() {
    super.initState();
    _pickerPosition = widget.initialCenter?.toLatLng() ??
        widget.start?.toLatLng();
    if (widget.showMyLocation) {
      _ensureLocationPermission();
    }
    if (widget.liveMarkers && _routePoints.length >= 2) {
      _interpolator = RouteInterpolator(_routePoints);
      _liveAnim = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 28),
      )..repeat();
      _liveAnim!.addListener(_tickLiveMarker);
      _liveDriverPosition = _interpolator!.positionAt(0);
    }
  }

  @override
  void didUpdateWidget(covariant SamewayMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liveMarkers != oldWidget.liveMarkers ||
        widget.start != oldWidget.start ||
        widget.end != oldWidget.end) {
      _interpolator = RouteInterpolator(_routePoints);
      _liveDriverPosition = _interpolator?.positionAt(_liveAnim?.value ?? 0);
    }
    if (widget.pickerMode && widget.initialCenter != oldWidget.initialCenter) {
      _pickerPosition = widget.initialCenter?.toLatLng();
      _moveCamera(_pickerPosition);
    }
  }

  Future<void> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _tickLiveMarker() {
    final interp = _interpolator;
    final anim = _liveAnim;
    if (interp == null || anim == null) return;
    setState(() {
      _liveDriverPosition = interp.positionAt(anim.value);
    });
  }

  @override
  void dispose() {
    _liveAnim?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _moveCamera(LatLng? target) async {
    if (target == null || _controller == null) return;
    await _controller!.animateCamera(CameraUpdate.newLatLng(target));
  }

  Future<void> _fitRoute() async {
    if (_controller == null || _routePoints.length < 2) return;
    final bounds = _boundsFor(_routePoints);
    await _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  LatLngBounds _boundsFor(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final route = _routePoints;

    if (!widget.pickerMode && route.isNotEmpty) {
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: route.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.start?.address ?? 'Start'),
      ));
    }

    if (!widget.pickerMode && route.length > 1) {
      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: route.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.end?.address ?? 'End'),
      ));
    }

    if (widget.liveMarkers && _liveDriverPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver_live'),
        position: _liveDriverPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: 'Driver', snippet: 'En route'),
        zIndex: 2,
      ));
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (widget.pickerMode || _routePoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: AppColors.primary,
        width: 5,
        geodesic: true,
        patterns: widget.liveMarkers
            ? [PatternItem.dash(20), PatternItem.gap(10)]
            : [],
      ),
    };
  }

  void _onCameraIdle() {
    if (!widget.pickerMode || _pickerPosition == null) return;
    widget.onPickerChanged?.call(
      MapLocationLatLng.fromLatLng(
        _pickerPosition!,
        address: widget.pickerAddress ?? 'Pinned location',
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!MapConfig.useNativeMaps) {
      return _UnavailableMap(height: widget.height, message: 'Maps on mobile only');
    }

    final radius = widget.borderRadius ?? AppRadius.md;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialTarget,
                zoom: widget.zoom ?? (widget.pickerMode ? 15 : MapConfig.routeZoom),
              ),
              onMapCreated: (c) async {
                _controller = c;
                setState(() => _mapReady = true);
                if (!widget.pickerMode && _routePoints.length >= 2) {
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                  await _fitRoute();
                }
              },
              onCameraMove: (position) {
                if (widget.pickerMode) {
                  _pickerPosition = position.target;
                }
              },
              onCameraIdle: _onCameraIdle,
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
              myLocationEnabled: widget.showMyLocation,
              myLocationButtonEnabled: widget.showMyLocation,
              zoomControlsEnabled: widget.pickerMode,
              compassEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: false,
            ),
            if (widget.pickerMode)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 44),
                      Container(
                        width: 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.liveMarkers)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.hint != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    widget.hint!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            if (!_mapReady)
              const ColoredBox(
                color: Color(0xFFE8EDF2),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableMap extends StatelessWidget {
  const _UnavailableMap({required this.height, required this.message});

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Shown when no API key is configured.
class MapKeyBanner extends StatelessWidget {
  const MapKeyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (MapConfig.hasApiKey) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryTint12,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Add GOOGLE_MAPS_API_KEY to android/local.properties (free mobile SDK).',
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
