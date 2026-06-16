import 'package:intl/intl.dart';
import 'package:sameway/core/maps/search_location_resolver.dart';
import 'package:sameway/core/models/search_location.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_placeholders.dart';

/// In-memory search context for the Find a Ride flow (search → results → detail).
class FindRideFlow {
  FindRideFlow._();

  static final instance = FindRideFlow._();

  String from = '';
  String to = '';
  double? fromLat;
  double? fromLng;
  double? toLat;
  double? toLng;
  String dateLabel = '';
  String arriveBy = '';
  int vehicleIndex = 0;
  int genderIndex = 0;
  int maxWalkMinutes = 10;
  int minMatchIndex = 1;
  String vehicleFilter = 'All';
  FindRideListing? selectedRide;
  String? lastRequestChatThreadId;
  String? lastRequestDriverName;

  static const vehicleOptions = ['Any', 'Car only', 'Bike ok'];
  static const genderOptions = ['No preference', 'Same gender'];
  static const minMatchOptions = ['50%+', '70%+', '90%+'];

  void hydrateFromSession() {
    final user = AppSession.instance.currentUser;
    final prefs = user?.commutePreferences;
    from = user?.homeAddress?.trim().isNotEmpty == true
        ? user!.homeAddress!
        : '';
    to = user?.officeAddress?.trim().isNotEmpty == true
        ? user!.officeAddress!
        : '';
    fromLat = user?.homeLat;
    fromLng = user?.homeLng;
    toLat = user?.officeLat;
    toLng = user?.officeLng;
    dateLabel = DateFormat('EEE, MMM d').format(DateTime.now());
    arriveBy = prefs?.arriveBy.trim().isNotEmpty == true
        ? prefs!.arriveBy
        : '';
    if (prefs != null) {
      final pv = prefs.preferredVehicle;
      vehicleIndex = pv == 'Car only'
          ? 1
          : pv == 'Bike ok'
              ? 2
              : 0;
      genderIndex = prefs.genderPreference == 'Same gender' ? 1 : 0;
      maxWalkMinutes = prefs.maxWalkMinutes;
    }
  }

  String get routeSubtitle {
    final fromLabel = from.isEmpty ? 'Start' : _shortPlace(from);
    final toLabel = to.isEmpty ? 'Destination' : _shortPlace(to);
    final day = dateLabel.isEmpty ? 'Today' : dateLabel;
    return '$fromLabel → $toLabel · $day';
  }

  String _shortPlace(String value) {
    final parts = value.split(',');
    return parts.first.trim();
  }

  String displayFrom() =>
      from.isEmpty ? AppPlaceholders.from : from;

  String displayTo() => to.isEmpty ? AppPlaceholders.to : to;

  String displayArriveBy() =>
      arriveBy.isEmpty ? AppPlaceholders.arriveBy : arriveBy;

  bool get hasValidSearchCoordinates =>
      SearchLocationResolver.hasValidCoords(fromLat, fromLng) &&
      SearchLocationResolver.hasValidCoords(toLat, toLng);

  /// Persist from/to text + coordinates on the flow (does not hit API).
  void setFromLocation(SearchLocation location) {
    from = location.address;
    fromLat = location.lat;
    fromLng = location.lng;
  }

  void setToLocation(SearchLocation location) {
    to = location.address;
    toLat = location.lat;
    toLng = location.lng;
  }

  void swapEndpoints() {
    final tempAddress = from;
    from = to;
    to = tempAddress;
    final tempLat = fromLat;
    fromLat = toLat;
    toLat = tempLat;
    final tempLng = fromLng;
    fromLng = toLng;
    toLng = tempLng;
  }

  /// Resolve coordinates from saved places or geocoding before search API call.
  Future<void> ensureSearchCoordinates() async {
    if (from.trim().isEmpty || to.trim().isEmpty) {
      throw StateError('Set both From and To before searching');
    }

    if (hasValidSearchCoordinates) {
      return;
    }

    final resolvedFrom = await SearchLocationResolver.resolveEndpoint(
      address: from,
      lat: fromLat,
      lng: fromLng,
    );
    final resolvedTo = await SearchLocationResolver.resolveEndpoint(
      address: to,
      lat: toLat,
      lng: toLng,
    );

    setFromLocation(resolvedFrom);
    setToLocation(resolvedTo);
  }

  /// Save resolved search endpoints as the user's HOME/OFFICE when they match.
  Future<void> persistMatchedSavedPlaces() async {
    final user = AppSession.instance.currentUser;
    if (user == null) return;

    final home = SearchLocationResolver.savedHome();
    if (home != null && SearchLocationResolver.addressesMatch(from, home.address)) {
      await AppSession.instance.syncPlace(
        label: 'HOME',
        address: from,
        lat: fromLat!,
        lng: fromLng!,
      );
    }

    final office = SearchLocationResolver.savedOffice();
    if (office != null && SearchLocationResolver.addressesMatch(to, office.address)) {
      await AppSession.instance.syncPlace(
        label: 'OFFICE',
        address: to,
        lat: toLat!,
        lng: toLng!,
      );
    }
  }
}

class FindRideListing {
  const FindRideListing({
    required this.id,
    required this.driverName,
    required this.driverFullName,
    required this.driverInitial,
    required this.company,
    required this.from,
    required this.to,
    required this.departTime,
    required this.arriveTime,
    required this.seats,
    required this.overlap,
    required this.rides,
    required this.onTimePct,
    required this.vehicleLabel,
    required this.vehicleDetail,
    required this.pickupLabel,
    required this.pickupDetail,
    required this.driverNote,
    this.isBike = false,
    this.coRiderName,
    this.coRiderInitial,
    this.kudos = const ['🚗 Smooth driver', '⏰ Punctual', '💬 Good chat'],
    this.matchScore = 0,
    this.walkMinutes = 0,
    this.distanceKm = 0,
    this.suggestedFareBDT = 0,
  });

  final String id;
  final String driverName;
  final String driverFullName;
  final String driverInitial;
  final String company;
  final String from;
  final String to;
  final String departTime;
  final String arriveTime;
  final int seats;
  final int overlap;
  final int rides;
  final int onTimePct;
  final String vehicleLabel;
  final String vehicleDetail;
  final String pickupLabel;
  final String pickupDetail;
  final String driverNote;
  final bool isBike;
  final String? coRiderName;
  final String? coRiderInitial;
  final List<String> kudos;

  /// Raw match score 0–100 returned by the backend matching algorithm.
  final int matchScore;

  /// Estimated walking minutes from the rider's pickup to the nearest route point.
  final int walkMinutes;

  /// Straight-line distance between driver's start and end in kilometres.
  final double distanceKm;

  /// Suggested fair-share cost in BDT (petrol only, 15 BDT/km, rounded to ৳5).
  final int suggestedFareBDT;

  factory FindRideListing.fromJson(Map<String, dynamic> json) => FindRideListing(
        id: json['id'] as String,
        driverName: json['driverName'] as String? ?? '',
        driverFullName: json['driverFullName'] as String? ?? '',
        driverInitial: json['driverInitial'] as String? ?? '?',
        company: json['company'] as String? ?? '',
        from: json['from'] as String? ?? '',
        to: json['to'] as String? ?? '',
        departTime: json['departTime'] as String? ?? '',
        arriveTime: json['arriveTime'] as String? ?? '',
        seats: json['seats'] as int? ?? 1,
        overlap: json['overlap'] as int? ?? json['matchScore'] as int? ?? 0,
        rides: json['rides'] as int? ?? 0,
        onTimePct: json['onTimePct'] as int? ?? 90,
        vehicleLabel: json['vehicleLabel'] as String? ?? '',
        vehicleDetail: json['vehicleDetail'] as String? ?? '',
        pickupLabel: json['pickupLabel'] as String? ?? '',
        pickupDetail: json['pickupDetail'] as String? ?? '',
        driverNote: json['driverNote'] as String? ?? '',
        isBike: json['isBike'] as bool? ?? false,
        coRiderName: json['coRiderName'] as String?,
        coRiderInitial: json['coRiderInitial'] as String?,
        kudos: (json['kudos'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const ['🚗 Smooth driver', '⏰ Punctual', '💬 Good chat'],
        matchScore: (json['matchScore'] as num?)?.toInt() ?? 0,
        walkMinutes: (json['walkMinutes'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        suggestedFareBDT: (json['suggestedFareBDT'] as num?)?.toInt() ?? 0,
      );
}

