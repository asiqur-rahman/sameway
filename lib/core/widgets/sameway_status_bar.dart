import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

class SamewayStatusBar extends StatelessWidget {
  const SamewayStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.now();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final label = '$hour:$minute';

    return SizedBox(
      height: AppSpacing.statusBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 12, color: AppColors.textPrimary),
                const SizedBox(width: 4),
                Icon(Icons.wifi, size: 12, color: AppColors.textPrimary),
                const SizedBox(width: 4),
                Icon(Icons.battery_full, size: 14, color: AppColors.textPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
