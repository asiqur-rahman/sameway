import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppSession.instance, AppDataStore.instance]),
      builder: (context, _) {
        final user = AppSession.instance.currentUser;
        final rideCount = AppDataStore.instance.rides.length;
        final initial = (user?.fullName.isNotEmpty == true)
            ? user!.fullName[0].toUpperCase()
            : '?';
        final verifiedLabel = user?.workEmailVerified == true ? 'Verified' : 'Pending';
        final vehicle = user?.vehicle;

        return SamewayScreen(
          bottomNavigationBar: const SamewayBottomNav(currentIndex: 3),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              16,
              AppSpacing.screenHorizontal,
              24,
            ),
            children: [
              Text(
                'MY PROFILE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Guest',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${user?.workEmail ?? ''} · $verifiedLabel',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'ACHIEVEMENTS'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: '🌟 $rideCount ride${rideCount == 1 ? '' : 's'}'),
                  const _Badge(label: '⭐ New member'),
                ],
              ),
              if (vehicle != null) ...[
                const SizedBox(height: 24),
                const _SectionTitle(title: 'MY VEHICLES'),
                const SizedBox(height: 8),
                _InfoCard(
                  title: vehicle.makeModel,
                  subtitle:
                      '${vehicle.color} · ${vehicle.seats} seat${vehicle.seats == 1 ? '' : 's'} · ${vehicle.licensePlate}',
                  trailing: vehicle.type == 'bike' ? '🏍️' : '🚗',
                ),
              ],
              if (user?.designation != null) ...[
                const SizedBox(height: 24),
                const _SectionTitle(title: 'WORK'),
                const SizedBox(height: 8),
                _InfoCard(
                  title: user!.companyName ?? 'Company',
                  subtitle: user.designation!,
                  trailing: '🏢',
                ),
              ],
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () async {
                  await AppSession.instance.signOut();
                  if (context.mounted) context.go(AppRoutes.splash);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(trailing, style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}
