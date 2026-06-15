import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
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
  List<FindRideListing> _listings = [];
  bool _loading = true;
  String? _error;

  List<FindRideListing> get _filtered {
    if (_vehicleFilter == 'Car') {
      return _listings.where((l) => !l.isBike).toList();
    }
    if (_vehicleFilter == 'Bike') {
      return _listings.where((l) => l.isBike).toList();
    }
    return _listings;
  }

  @override
  void initState() {
    super.initState();
    _vehicleFilter = FindRideFlow.instance.vehicleFilter;
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final flow = FindRideFlow.instance;
    try {
      final fromLat = flow.fromLat ?? 23.8759;
      final fromLng = flow.fromLng ?? 90.3795;
      final toLat = flow.toLat ?? 23.7330;
      final toLng = flow.toLng ?? 90.4172;

      final vehicleFilter = switch (flow.vehicleIndex) {
        1 => 'CAR',
        2 => 'BIKE',
        _ => 'ANY',
      };
      final genderPreference = flow.genderIndex == 1 ? 'SAME' : 'NONE';
      final minMatchScore = switch (flow.minMatchIndex) {
        0 => 50,
        2 => 90,
        _ => 70,
      };

      final results = await RidesRepository.instance.search(
        fromLat: fromLat,
        fromLng: fromLng,
        toLat: toLat,
        toLng: toLng,
        fromAddress: flow.from.isNotEmpty ? flow.from : null,
        toAddress: flow.to.isNotEmpty ? flow.to : null,
        vehicleFilter: vehicleFilter,
        genderPreference: genderPreference,
        minMatchScore: minMatchScore,
        maxWalkingMinutes: flow.maxWalkMinutes,
      );
      if (!mounted) return;
      setState(() {
        _listings = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _listings = sampleFindRideListings;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = FindRideFlow.instance;
    final results = _filtered;
    final countLabel = _loading
        ? 'Searching…'
        : '${results.length} Ride${results.length == 1 ? '' : 's'} Found';

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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Text(
                'Using demo results — $_error',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
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
                      if (results.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No rides match your route yet. Try adjusting filters.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                          ),
                        ),
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
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
