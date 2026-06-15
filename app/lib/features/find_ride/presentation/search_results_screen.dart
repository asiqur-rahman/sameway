import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';
import 'package:sameway/features/find_ride/presentation/widgets/find_ride_widgets.dart';

/// Wireframe v2 — ScreenSearchResults.
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _vehicleFilter = 'All';

  List<FindRideListing> get _filtered {
    final listings = sampleFindRideListings;
    if (_vehicleFilter == 'Car') {
      return listings.where((l) => !l.isBike).toList();
    }
    if (_vehicleFilter == 'Bike') {
      return listings.where((l) => l.isBike).toList();
    }
    return listings;
  }

  @override
  void initState() {
    super.initState();
    _vehicleFilter = FindRideFlow.instance.vehicleFilter;
  }

  @override
  Widget build(BuildContext context) {
    final flow = FindRideFlow.instance;
    final results = _filtered;
    final countLabel = '${results.length + 5} Rides Found';

    return SamewayScreen(
      bottomNavigationBar: const SamewayBottomNav(currentIndex: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobilePageHeader(
            title: countLabel,
            subtitle: flow.routeSubtitle,
            backFallback: AppRoutes.searchFilters,
            trailing: GestureDetector(
              onTap: () => context.push(AppRoutes.searchFilters),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Filter',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                12,
                AppSpacing.screenHorizontal,
                88,
              ),
              children: [
                const FindResultsMapStrip(),
                const SizedBox(height: 12),
                FindSortFilterRow(
                  vehicleFilter: _vehicleFilter,
                  onFilterChanged: (f) => setState(() {
                    _vehicleFilter = f;
                    FindRideFlow.instance.vehicleFilter = f;
                  }),
                ),
                const SizedBox(height: 12),
                for (final listing in results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FindRideResultCard(
                      listing: listing,
                      onTap: () {
                        FindRideFlow.instance.selectedRide = listing;
                        context.push(AppRoutes.rideDetail);
                      },
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+ 5 more rides · Load more',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
