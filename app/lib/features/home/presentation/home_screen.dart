import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
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

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => context.push(AppRoutes.postRideEmpty),
              ),
              const SizedBox(height: 12),
              const OrDivider(),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.postRideEmpty),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No active rides yet',
            style: AppTypography.caption,
          ),
        ),
      ],
    );
  }
}

class _FindTabContent extends StatelessWidget {
  const _FindTabContent();

  @override
  Widget build(BuildContext context) {
    final user = AppSession.instance.currentUser;
    final prefs = user?.commutePreferences;
    final from = user?.homeAddress?.trim().isNotEmpty == true
        ? user!.homeAddress!
        : AppPlaceholders.from;
    final to = user?.officeAddress?.trim().isNotEmpty == true
        ? user!.officeAddress!
        : AppPlaceholders.to;
    final arriveBy = prefs?.arriveBy.trim().isNotEmpty == true
        ? prefs!.arriveBy
        : AppPlaceholders.arriveBy;
    final dateLabel = DateFormat('EEE, MMM d').format(DateTime.now());

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
                  value: from,
                  isOrigin: true,
                ),
                const Divider(height: 1, indent: 38),
                LocationFieldRow(
                  label: 'To',
                  value: to,
                  isOrigin: false,
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
                value: dateLabel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateTimeFieldTile(
                emoji: '⏰',
                label: 'Arrive by',
                value: arriveBy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const FindPreferencesRow(),
        const SizedBox(height: 12),
        SamewayDarkButton(
          label: '🔍  Search Rides',
          onPressed: () {
            FindRideFlow.instance
              ..hydrateFromSession()
              ..from = user?.homeAddress?.trim() ?? ''
              ..to = user?.officeAddress?.trim() ?? ''
              ..dateLabel = dateLabel
              ..arriveBy = prefs?.arriveBy.trim() ?? '';
            context.push(AppRoutes.searchFilters);
          },
        ),
        const SizedBox(height: 16),
        Text(
          'RECENT SEARCHES',
          style: AppTypography.sectionOverline,
        ),
        const SizedBox(height: 8),
        RecentSearchRow(
          label: '$from → $to · $dateLabel',
        ),
      ],
    );
  }
}
