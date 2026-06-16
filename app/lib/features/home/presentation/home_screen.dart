import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/utils/commute_time_format.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_tab_switcher.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';
import 'package:sameway/features/home/presentation/widgets/add_vehicle_sheet.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = AppSession.instance.currentUser?.defaultHomeTab ??
        OnboardingState.instance.defaultHomeTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDataStore.instance.refreshBookings();
    });
  }

  Future<void> _onTabChanged(int index) async {
    if (index == 0 &&
        !OnboardingState.instance.isDriver &&
        !OnboardingState.instance.hasVehicleDetails) {
      final saved = await showAddVehicleSheet(context);
      if (!mounted) return;
      if (saved == true) {
        setState(() => _tabIndex = 0);
      }
      return;
    }
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final user = AppSession.instance.currentUser;
        final state = OnboardingState.instance;
        final dateLabel = DateFormat('EEE, MMM d').format(DateTime.now());
        final greetingName = user?.firstName ?? 'there';
        final headerTitle = _tabIndex == 1 && state.isDriver
            ? 'Find a Ride'
            : 'Good morning, $greetingName!';

        return SamewayScreen(
          bottomNavigationBar: const SamewayBottomNav(currentIndex: 0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  12,
                  AppSpacing.screenHorizontal,
                  10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$dateLabel · Dhaka',
                            style: AppTypography.greetingMeta,
                          ),
                          Text(
                            headerTitle,
                            style: AppTypography.greetingTitle,
                          ),
                        ],
                      ),
                    ),
                    if (!state.isDriver) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🧍', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          state.isWalker ? 'Walker' : 'Rider',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (state.isDriver)
                  Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: SamewayDecorations.iconButton(),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.dark_mode_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.notificationCentre),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: SamewayDecorations.iconButton(),
                        alignment: Alignment.center,
                        child: const Text('🔔', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              12,
              AppSpacing.screenHorizontal,
              0,
            ),
            child: SamewayTabSwitcher(
              tabs: const ['🚗 Offer a Ride', '🔍 Find a Ride'],
              selectedIndex: _tabIndex,
              onChanged: _onTabChanged,
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? const _OfferTabContent() : const _FindTabContent(),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _OfferTabContent extends StatelessWidget {
  const _OfferTabContent();

  Future<void> _prefillAndPost(BuildContext context, {bool once = false}) async {
    final user = AppSession.instance.currentUser;
    final vehicle = user?.vehicle;
    await AppDataStore.instance.updatePostRideDraft((d) {
      if (user?.homeAddress?.trim().isNotEmpty == true) {
        d.startAddress = user!.homeAddress;
      }
      if (user?.officeAddress?.trim().isNotEmpty == true) {
        d.endAddress = user!.officeAddress;
      }
      d.dateLabel = DateFormat('EEE, MMM d').format(DateTime.now());
      if (vehicle?.usuallyLeave.trim().isNotEmpty == true) {
        d.departTime = vehicle!.usuallyLeave;
      }
      d.seats = vehicle?.seats ?? 2;
      d.repeat = once ? 'Once' : 'Weekdays';
    });
    if (!context.mounted) return;
    final route = AppDataStore.instance.postRideDraft.hasRoute
        ? AppRoutes.postRideFilled
        : AppRoutes.postRideEmpty;
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final user = AppSession.instance.currentUser;
        final vehicle = user?.vehicle;
        final seats = vehicle?.seats ?? 2;
        final routeFrom = user?.homeAddress?.trim().isNotEmpty == true
            ? user!.homeAddress!
            : AppPlaceholders.from;
        final routeTo = user?.officeAddress?.trim().isNotEmpty == true
            ? user!.officeAddress!
            : AppPlaceholders.to;
        final leaveTime = vehicle?.usuallyLeave.trim().isNotEmpty == true
            ? vehicle!.usuallyLeave
            : null;
        final schedule = leaveTime != null
            ? 'Mon–Fri · $leaveTime · $seats seat${seats == 1 ? '' : 's'} available'
            : 'Mon–Fri · $seats seat${seats == 1 ? '' : 's'} available';
        final activeRides = AppDataStore.instance.upcomingRides
            .where((r) => r.isDriver)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            16,
            AppSpacing.screenHorizontal,
            16,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: SamewayDecorations.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel(label: 'Regular Route — Quick Post'),
                  const SizedBox(height: 12),
                  RouteTimeline(
                    route: '$routeFrom → $routeTo',
                    schedule: schedule,
                  ),
                  const SizedBox(height: 12),
                  SamewayDarkButton(
                    label: '🚗  Post for Today — 1 tap',
                    onPressed: () => _prefillAndPost(context, once: true),
                  ),
                  const SizedBox(height: 12),
                  const OrDivider(),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: () => _prefillAndPost(context),
                      child: Text(
                        '＋  Create a different / new ride',
                        style: AppTypography.linkAction,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Goes to full Post a Ride screen — new route, new time',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ACTIVE RIDES',
              style: AppTypography.sectionOverline,
            ),
            const SizedBox(height: 8),
            if (activeRides.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active rides yet',
                  style: AppTypography.caption,
                ),
              )
            else
              ...activeRides.map(
                (ride) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: SamewayDecorations.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.timeLabel,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(ride.route, style: AppTypography.fieldValue),
                        Text(ride.detail, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FindTabContent extends StatefulWidget {
  const _FindTabContent();

  @override
  State<_FindTabContent> createState() => _FindTabContentState();
}

class _FindTabContentState extends State<_FindTabContent> {
  late String _from;
  late String _to;
  late String _dateLabel;
  late String _arriveBy;
  late bool _carSelected;
  late bool _bikeSelected;
  late bool _anyGenderSelected;

  @override
  void initState() {
    super.initState();
    _loadFromFlow();
  }

  void _loadFromFlow() {
    FindRideFlow.instance.hydrateFromSession();
    final flow = FindRideFlow.instance;
    final prefs = AppSession.instance.currentUser?.commutePreferences;
    _from = flow.from;
    _to = flow.to;
    _dateLabel = flow.dateLabel;
    _arriveBy = flow.arriveBy;
    switch (prefs?.preferredVehicle) {
      case 'Car only':
        _carSelected = true;
        _bikeSelected = false;
        break;
      case 'Bike ok':
        _carSelected = false;
        _bikeSelected = true;
        break;
      default:
        _carSelected = true;
        _bikeSelected = true;
    }
    _anyGenderSelected = prefs?.genderPreference != 'Same gender';
  }

  String _displayFrom() =>
      _from.trim().isEmpty ? AppPlaceholders.from : _from;

  String _displayTo() => _to.trim().isEmpty ? AppPlaceholders.to : _to;

  String _displayArriveBy() =>
      _arriveBy.trim().isEmpty ? AppPlaceholders.arriveBy : _arriveBy;

  bool get _fromIsPlaceholder => _from.trim().isEmpty;

  bool get _toIsPlaceholder => _to.trim().isEmpty;

  Future<void> _editFrom() async {
    final flow = FindRideFlow.instance;
    final picked = await showHomeLocationPicker(
      context,
      title: 'From — where are you leaving?',
      initial: _from.trim().isEmpty ? null : _from,
      initialLat: flow.fromLat,
      initialLng: flow.fromLng,
    );
    if (picked != null && picked.isValid && mounted) {
      setState(() => _from = picked.address);
      flow.setFromLocation(picked);
    }
  }

  Future<void> _editTo() async {
    final flow = FindRideFlow.instance;
    final picked = await showHomeLocationPicker(
      context,
      title: 'To — where are you going?',
      initial: _to.trim().isEmpty ? null : _to,
      initialLat: flow.toLat,
      initialLng: flow.toLng,
    );
    if (picked != null && picked.isValid && mounted) {
      setState(() => _to = picked.address);
      flow.setToLocation(picked);
    }
  }

  void _swapFromTo() {
    FindRideFlow.instance.swapEndpoints();
    final flow = FindRideFlow.instance;
    setState(() {
      _from = flow.from;
      _to = flow.to;
    });
  }

  Future<void> _pickDate() async {
    final initial = _tryParseDate(_dateLabel) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _dateLabel = DateFormat('EEE, MMM d').format(picked));
    }
  }

  Future<void> _pickArriveBy() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: CommuteTimeFormat.parse(_arriveBy) ??
          const TimeOfDay(hour: 9, minute: 30),
    );
    if (picked != null) {
      setState(() => _arriveBy = CommuteTimeFormat.format(picked));
    }
  }

  DateTime? _tryParseDate(String label) {
    try {
      return DateFormat('EEE, MMM d').parse(label);
    } catch (_) {
      return null;
    }
  }

  int _vehicleIndex() {
    if (_carSelected && _bikeSelected) return 0;
    if (_carSelected) return 1;
    if (_bikeSelected) return 2;
    return 0;
  }

  void _syncToFlow() {
    if (_from.trim().isEmpty || _to.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set both From and To before searching')),
      );
      return;
    }
    final flow = FindRideFlow.instance;
    flow
      ..from = _from.trim()
      ..to = _to.trim()
      ..dateLabel = _dateLabel
      ..arriveBy = _arriveBy.trim()
      ..vehicleIndex = _vehicleIndex()
      ..genderIndex = _anyGenderSelected ? 0 : 1
      ..vehicleFilter = 'All';
    context.push(AppRoutes.searchFilters);
  }

  @override
  Widget build(BuildContext context) {
    final recentLabel =
        '${_fromIsPlaceholder ? 'Start' : _from.split(',').first.trim()} → '
        '${_toIsPlaceholder ? 'Destination' : _to.split(',').first.trim()} · $_dateLabel';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        12,
        AppSpacing.screenHorizontal,
        16,
      ),
      children: [
        const FindRideMapPreview(),
        const SizedBox(height: 12),
        Transform.translate(
          offset: const Offset(0, -18),
          child: Container(
            decoration: SamewayDecorations.card(radius: 18),
            child: Column(
              children: [
                LocationFieldRow(
                  label: 'From',
                  value: _displayFrom(),
                  isOrigin: true,
                  mutedValue: _fromIsPlaceholder,
                  onTap: _editFrom,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _swapFromTo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '↕ Swap',
                          style: AppTypography.chipLabel(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 38),
                LocationFieldRow(
                  label: 'To',
                  value: _displayTo(),
                  isOrigin: false,
                  mutedValue: _toIsPlaceholder,
                  onTap: _editTo,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 0),
        Row(
          children: [
            Expanded(
              child: DateTimeFieldTile(
                emoji: '📅',
                label: 'Date',
                value: _dateLabel,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateTimeFieldTile(
                emoji: '⏰',
                label: 'Arrive by',
                value: _displayArriveBy(),
                mutedValue: _arriveBy.trim().isEmpty,
                onTap: _pickArriveBy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FindPreferencesRow(
          carSelected: _carSelected,
          bikeSelected: _bikeSelected,
          anyGenderSelected: _anyGenderSelected,
          onCarChanged: (v) => setState(() => _carSelected = v),
          onBikeChanged: (v) => setState(() => _bikeSelected = v),
          onAnyGenderChanged: (v) => setState(() => _anyGenderSelected = v),
        ),
        const SizedBox(height: 12),
        SamewayDarkButton(
          label: '🔍  Search Rides',
          onPressed: _syncToFlow,
        ),
        const SizedBox(height: 16),
        Text(
          'RECENT SEARCHES',
          style: AppTypography.sectionOverline,
        ),
        const SizedBox(height: 8),
        RecentSearchRow(
          label: recentLabel,
          onTap: _syncToFlow,
        ),
      ],
    );
  }
}
