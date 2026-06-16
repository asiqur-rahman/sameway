import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/api_error_message.dart';
import 'package:sameway/core/api/api_exception.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
import 'package:sameway/core/maps/search_location_resolver.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_loading.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_secondary_button.dart';
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
  bool _refreshing = false;
  String? _errorMessage;

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

  Future<void> _loadResults({bool refresh = false}) async {
    setState(() {
      _errorMessage = null;
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }
    });
    final flow = FindRideFlow.instance;
    try {
      await flow.ensureSearchCoordinates();

      if (!SearchLocationResolver.hasValidCoords(flow.fromLat, flow.fromLng) ||
          !SearchLocationResolver.hasValidCoords(flow.toLat, flow.toLng)) {
        throw StateError('Set both locations on the map before searching.');
      }

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
        fromLat: flow.fromLat!,
        fromLng: flow.fromLng!,
        toLat: flow.toLat!,
        toLng: flow.toLng!,
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
        _refreshing = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _listings = [];
        _loading = false;
        _refreshing = false;
        _errorMessage = ApiErrorMessage.compose(
          message: e.message,
          code: e.code,
          details: e.details,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listings = [];
        _loading = false;
        _refreshing = false;
        _errorMessage = ApiErrorMessage.fromUnknown(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = FindRideFlow.instance;
    final results = _filtered;
    final countLabel = _loading && !_refreshing
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
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _loadResults(refresh: true),
              child: _loading && !_refreshing
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        12,
                        AppSpacing.screenHorizontal,
                        88,
                      ),
                      children: const [
                        FindResultsMapStrip(),
                        SizedBox(height: 12),
                        RideListingSkeleton(),
                        SizedBox(height: 12),
                        RideListingSkeleton(),
                        SizedBox(height: 12),
                        RideListingSkeleton(),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        12,
                        AppSpacing.screenHorizontal,
                        88,
                      ),
                      children: [
                        const FindResultsMapStrip(),
                        const SizedBox(height: 12),
                        if (_errorMessage != null) ...[
                          EmptyStateInline(
                            icon: '⚠️',
                            message: _errorMessage!,
                            actionLabel: 'Try again',
                            onAction: () => _loadResults(refresh: true),
                          ),
                          const SizedBox(height: 12),
                          SamewaySecondaryButton(
                            label: 'Edit search',
                            onPressed: () => context.push(AppRoutes.searchFilters),
                          ),
                        ] else ...[
                          FindSortFilterRow(
                            vehicleFilter: _vehicleFilter,
                            onFilterChanged: (f) => setState(() {
                              _vehicleFilter = f;
                              FindRideFlow.instance.vehicleFilter = f;
                            }),
                          ),
                          const SizedBox(height: 12),
                          if (results.isEmpty)
                            const EmptyStateInline(
                              icon: '🚗',
                              message:
                                  'No drivers on this route yet.\n'
                                  'Try lowering the match % on filters, or post a ride from the Offer tab.\n\n'
                                  'Dev tip: run `npm run db:seed` in backend for a demo Uttara → Motijheel ride.',
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
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateInline extends StatelessWidget {
  const EmptyStateInline({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: AppColors.textMuted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SamewayDarkButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
