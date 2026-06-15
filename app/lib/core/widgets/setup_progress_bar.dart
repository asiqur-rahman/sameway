import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';

/// Onboarding progress — Personal → Commute → Verify (wireframes v2).
class SetupProgressBar extends StatelessWidget {
  const SetupProgressBar({super.key, required this.step});

  final int step;

  static const _labels = ['Personal', 'Commute', 'Verify'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
        Row(
          children: [
            for (var i = 1; i <= 3; i++) ...[
              if (i > 1) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step ? AppColors.primary : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Text(
                  _labels[i],
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == 2
                          ? TextAlign.right
                          : TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: i + 1 == step ? FontWeight.w700 : FontWeight.w400,
                    color: i + 1 == step
                        ? AppColors.primary
                        : i + 1 < step
                            ? AppColors.textSecondary
                            : AppColors.border,
                  ),
                ),
              ),
          ],
        ),
      ],
      ),
    );
  }
}
