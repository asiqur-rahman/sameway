import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sameway/core/maps/map_config.dart';
import 'package:sameway/core/maps/map_location_latlng.dart';
import 'package:sameway/core/maps/route_interpolator.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

/// OpenStreetMap view with route polyline, pin picker, and live marker animation.
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
  final MapController _mapController = MapController();
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

  double get _initialZoom {
    return widget.zoom ?? (widget.pickerMode ? MapConfig.pickerZoom : MapConfig.routeZoom);
  }

  @override
  void initState() {
    super.initState();
    _pickerPosition = widget.initialCenter?.toLatLng() ?? widget.start?.toLatLng();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.pickerMode && _routePoints.length >= 2) {
        _fitRoute();
      }
      if (mounted) setState(() => _mapReady = true);
    });
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
      _mapController.move(_pickerPosition ?? _initialTarget, _mapController.camera.zoom);
    }
  }

  Future<void> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (widget.pickerMode && _pickerPosition == null) {
        setState(() {
          _pickerPosition = LatLng(pos.latitude, pos.longitude);
        });
        _mapController.move(_pickerPosition!, MapConfig.pickerZoom);
      }
    } catch (_) {}
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
    _mapController.dispose();
    super.dispose();
  }

  void _fitRoute() {
    if (_routePoints.length < 2) return;
    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  void _notifyPicker() {
    if (!widget.pickerMode || _pickerPosition == null) return;
    widget.onPickerChanged?.call(
      MapLocationLatLng.fromLatLng(
        _pickerPosition!,
        address: widget.pickerAddress ?? 'Pinned location',
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    final route = _routePoints;

    if (!widget.pickerMode && route.isNotEmpty) {
      markers.add(_pointMarker(
        route.first,
        color: Colors.green,
        label: widget.start?.address ?? 'Start',
      ));
    }

    if (!widget.pickerMode && route.length > 1) {
      markers.add(_pointMarker(
        route.last,
        color: Colors.red,
        label: widget.end?.address ?? 'End',
      ));
    }

    if (widget.liveMarkers && _liveDriverPosition != null) {
      markers.add(_pointMarker(
        _liveDriverPosition!,
        color: AppColors.primary,
        label: 'Driver',
        icon: Icons.directions_car,
      ));
    }

    return markers;
  }

  Marker _pointMarker(
    LatLng point, {
    required Color color,
    required String label,
    IconData icon = Icons.place,
  }) {
    return Marker(
      point: point,
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: Tooltip(
        message: label,
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppRadius.md;
    final route = _routePoints;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialTarget,
                initialZoom: _initialZoom,
                minZoom: 5,
                maxZoom: 18,
                interactionOptions: InteractionOptions(
                  flags: widget.pickerMode || widget.showMyLocation
                      ? InteractiveFlag.all
                      : InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                onMapEvent: (event) {
                  if (widget.pickerMode && event is MapEventMoveEnd) {
                    _pickerPosition = event.camera.center;
                    _notifyPicker();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConfig.tileUrl,
                  userAgentPackageName: MapConfig.userAgentPackageName,
                ),
                if (!widget.pickerMode && route.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        color: AppColors.primary,
                        strokeWidth: 4,
                        pattern: widget.liveMarkers
                            ? StrokePattern.dashed(segments: const [12, 8])
                            : const StrokePattern.solid(),
                      ),
                    ],
                  ),
                if (_buildMarkers().isNotEmpty) MarkerLayer(markers: _buildMarkers()),
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  showFlutterMapAttribution: false,
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            if (widget.pickerMode)
              IgnorePointer(
                child: Center(
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
                bottom: 28,
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

/// OSM attribution — always shown (required by tile license).
class MapAttributionBanner extends StatelessWidget {
  const MapAttributionBanner({super.key});

  @override
  Widget build(BuildContext context) {
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
        'Maps © OpenStreetMap — free, no API key required.',
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Kept for backwards compatibility — use [MapAttributionBanner].
typedef MapKeyBanner = MapAttributionBanner;
