import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/constants/app_brand.dart';
import 'package:sameway/core/theme/app_colors.dart';

class WebScaffold extends StatelessWidget {
  const WebScaffold({
    super.key,
    required this.child,
    this.activeNav,
    this.showNav = true,
  });

  final Widget child;
  final String? activeNav;
  final bool showNav;

  static const _links = [
    'How it Works',
    'Find a Ride',
    'Post a Ride',
    'Sign In',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (showNav)
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Text(
                    kAppName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 40),
                  ..._links.map(
                    (link) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        link,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: activeNav == link
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: activeNav == link
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebHero extends StatelessWidget {
  const WebHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.cta,
  });

  final String title;
  final String subtitle;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (cta != null) ...[const SizedBox(height: 24), cta!],
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('🚗', style: TextStyle(fontSize: 80)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
