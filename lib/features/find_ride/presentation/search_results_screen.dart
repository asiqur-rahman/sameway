import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  static const _results = [
    _SearchResult(
      driver: 'Karim R.',
      route: 'Uttara Sector 4 → Motijheel',
      time: 'Today · 8:30 AM',
      vehicle: '🚗 Toyota Allion',
      match: '92%',
    ),
    _SearchResult(
      driver: 'Nusrat A.',
      route: 'Uttara → Farmgate → Motijheel',
      time: 'Today · 8:45 AM',
      vehicle: '🚗 Honda City',
      match: '87%',
    ),
    _SearchResult(
      driver: 'Imran H.',
      route: 'Azampur → Motijheel',
      time: 'Today · 9:00 AM',
      vehicle: '🚗 Toyota Axio',
      match: '81%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobilePageHeader(
            title: 'Search Results',
            subtitle: 'Uttara → Motijheel · Today',
            onBack: () => context.pop(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: const SectionHeader('MATCHING ROUTES'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                24,
              ),
              itemCount: _results.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final result = _results[index];
                return _RideResultCard(
                  result: result,
                  onTap: () => context.push(AppRoutes.rideDetail),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.driver,
    required this.route,
    required this.time,
    required this.vehicle,
    required this.match,
  });

  final String driver;
  final String route;
  final String time;
  final String vehicle;
  final String match;
}

class _RideResultCard extends StatelessWidget {
  const _RideResultCard({
    required this.result,
    required this.onTap,
  });

  final _SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.125),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text('🚗', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        result.driver,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('✓', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.route,
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.time} · ${result.vehicle}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryTint7,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result.match,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
