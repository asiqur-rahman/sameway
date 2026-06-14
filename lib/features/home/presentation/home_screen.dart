import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_tab_switcher.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, MMM d').format(DateTime.now());

    return SamewayScreen(
      bottomNavigationBar: const SamewayBottomNav(currentIndex: 0),
      child: Column(
        children: [
          Container(
            height: 66,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dateLabel · Uttara, Dhaka',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        'Good morning, Rafiq!',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          letterSpacing: -0.6,
                          color: AppColors.textPrimary,
                          height: 26.625 / 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🔔', style: TextStyle(fontSize: 20)),
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
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? const _OfferTabContent() : const _FindTabContent(),
          ),
        ],
      ),
    );
  }
}

class _OfferTabContent extends StatelessWidget {
  const _OfferTabContent();

  @override
  Widget build(BuildContext context) {
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
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel(label: 'REGULAR ROUTE — QUICK POST'),
              const SizedBox(height: 12),
              const RouteTimeline(
                route: 'Uttara Sector 4 → Motijheel',
                schedule: 'Mon–Fri · 8:30 AM · 2 seats available',
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: FilledButton(
                  onPressed: () => context.push(AppRoutes.incomingRequests),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    '🚗 Post for Today — 1 tap',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const OrDivider(),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.postRideEmpty),
                  child: Text(
                    '＋ Create a different / new ride',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Goes to full Post a Ride screen — new route, new time',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ACTIVE RIDES',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        const ActiveRideCard(
          timeLabel: 'Tomorrow · 8:30 AM',
          routeLabel: 'Uttara → Motijheel · 2 riders confirmed',
        ),
      ],
    );
  }
}

class _FindTabContent extends StatelessWidget {
  const _FindTabContent();

  static final _fromController = TextEditingController(text: 'Uttara Sector 4, Dhaka');
  static final _toController = TextEditingController(text: 'Motijheel, Dhaka');
  static final _dateController = TextEditingController();
  static final _timeController = TextEditingController(text: '9:30 AM');

  @override
  Widget build(BuildContext context) {
    _dateController.text = 'Today, ${DateFormat('MMM d').format(DateTime.now())}';

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
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SamewayTextField(
                label: 'From',
                icon: '📍',
                controller: _fromController,
              ),
              const SizedBox(height: 8),
              SamewayTextField(
                label: 'To',
                icon: '🏢',
                controller: _toController,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SamewayTextField(
                      label: 'Date',
                      controller: _dateController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SamewayTextField(
                      label: 'Arrive by',
                      controller: _timeController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'PREFERENCES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  PreferenceChip(label: '🚗 Car', selected: true),
                  PreferenceChip(label: '🏍 Bike ok'),
                  PreferenceChip(label: 'Any gender', selected: true),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: FilledButton(
                  onPressed: () => context.push(AppRoutes.searchResults),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Search Rides',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'RECENT SEARCHES',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        const RecentSearchRow(
          label: 'Uttara Sec 4 → Motijheel · Today 8:30 AM',
        ),
        const SizedBox(height: 8),
        const RecentSearchRow(
          label: 'Uttara Sec 4 → Gulshan 1 · Yesterday',
        ),
      ],
    );
  }
}
