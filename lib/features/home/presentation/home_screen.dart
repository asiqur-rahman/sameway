import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(bottom: BorderSide(color: AppColors.border)),
              boxShadow: AppShadows.soft,
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
                        style: AppTypography.greetingMeta,
                      ),
                      Text(
                        'Good morning, Rafiq!',
                        style: AppTypography.greetingTitle,
                      ),
                    ],
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
          decoration: SamewayDecorations.card(),
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
                  onPressed: () => context.push(AppRoutes.postRideEmpty),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    '🚗 Post for Today — 1 tap',
                    style: AppTypography.buttonPrimary,
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
                    style: AppTypography.link,
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
        const ActiveRideCard(
          timeLabel: 'Tomorrow · 8:30 AM',
          routeLabel: 'Uttara → Motijheel · 2 riders confirmed',
          onTapRoute: AppRoutes.departureIn,
        ),
      ],
    );
  }
}

class _FindTabContent extends StatelessWidget {
  const _FindTabContent();

  static final _fromController = TextEditingController();
  static final _toController = TextEditingController();
  static final _dateController = TextEditingController();
  static final _timeController = TextEditingController();

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
          decoration: SamewayDecorations.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SamewayTextField(
                label: 'From',
                icon: '📍',
                hint: AppPlaceholders.from,
                controller: _fromController,
              ),
              const SizedBox(height: 8),
              SamewayTextField(
                label: 'To',
                icon: '🏢',
                hint: AppPlaceholders.to,
                controller: _toController,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SamewayTextField(
                      label: 'Date',
                      hint: AppPlaceholders.date,
                      controller: _dateController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SamewayTextField(
                      label: 'Arrive by',
                      hint: AppPlaceholders.arriveBy,
                      controller: _timeController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'PREFERENCES',
                style: AppTypography.sectionOverline,
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  PreferenceChip(
                    label: '🚗 Car',
                    selected: true,
                    useRoboto: true,
                  ),
                  PreferenceChip(label: '🏍 Bike ok'),
                  PreferenceChip(label: 'Any gender', selected: true),
                ],
              ),
              const SizedBox(height: 8),
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
                    style: AppTypography.searchButton,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'RECENT SEARCHES',
          style: AppTypography.sectionOverline,
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
