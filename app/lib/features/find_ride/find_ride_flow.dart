import 'package:intl/intl.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_placeholders.dart';

/// In-memory search context for the Find a Ride flow (search → results → detail).
class FindRideFlow {
  FindRideFlow._();

  static final instance = FindRideFlow._();

  String from = '';
  String to = '';
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
}

const sampleFindRideListings = [
  FindRideListing(
    id: '1',
    driverName: 'Karim R.',
    driverFullName: 'Karim Rahman',
    driverInitial: 'K',
    company: 'Grameenphone',
    from: 'Uttara Sec 4',
    to: 'Motijheel',
    departTime: '8:25 AM',
    arriveTime: '~9:15 AM',
    seats: 2,
    overlap: 94,
    rides: 47,
    onTimePct: 96,
    vehicleLabel: '🚗 Toyota Allion',
    vehicleDetail: 'White · 4 seats',
    pickupLabel: 'Your pickup (3 min walk)',
    pickupDetail: 'Uttara Bus Stand · Gate 2',
    driverNote:
        '"No smoking. Music ok. Usually early. Cost split by mutual agreement."',
    coRiderName: 'Sadia M.',
    coRiderInitial: 'S',
  ),
  FindRideListing(
    id: '2',
    driverName: 'Nasrin A.',
    driverFullName: 'Nasrin Ahmed',
    driverInitial: 'N',
    company: 'Banglalink',
    from: 'Uttara-10',
    to: 'Motijheel',
    departTime: '8:35 AM',
    arriveTime: '~9:20 AM',
    seats: 1,
    overlap: 89,
    rides: 31,
    onTimePct: 94,
    vehicleLabel: '🚗 Honda City',
    vehicleDetail: 'Silver · 4 seats',
    pickupLabel: 'Your pickup (5 min walk)',
    pickupDetail: 'Abdullahpur Mor',
    driverNote: '"Prefer quiet rides. AC on."',
  ),
  FindRideListing(
    id: '3',
    driverName: 'Jahid K.',
    driverFullName: 'Jahid Khan',
    driverInitial: 'J',
    company: 'BRAC',
    from: 'Abdullahpur',
    to: 'Motijheel',
    departTime: '8:15 AM',
    arriveTime: '~9:05 AM',
    seats: 2,
    overlap: 78,
    rides: 22,
    onTimePct: 91,
    vehicleLabel: '🏍 Yamaha FZ',
    vehicleDetail: 'Black · 1 seat',
    pickupLabel: 'Your pickup (4 min walk)',
    pickupDetail: 'Uttara House Building',
    driverNote: '"Helmet provided. One pillion only."',
    isBike: true,
  ),
];
