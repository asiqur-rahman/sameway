import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/web_scaffold.dart';

class WebPostRideScreen extends StatelessWidget {
  WebPostRideScreen({super.key});

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _timeController = TextEditingController();
  final _seatsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      activeNav: 'Post a Ride',
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post a Ride',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SamewayTextField(
                          label: 'From',
                          icon: '📍',
                          hint: AppPlaceholders.from,
                          controller: _fromController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SamewayTextField(
                          label: 'To',
                          icon: '🏢',
                          hint: AppPlaceholders.to,
                          controller: _toController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SamewayTextField(
                          label: 'Departure time',
                          hint: AppPlaceholders.departureTime,
                          controller: _timeController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SamewayTextField(
                          label: 'Available seats',
                          hint: AppPlaceholders.seats,
                          controller: _seatsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SamewayDarkButton(
                    label: 'Post Ride',
                    textStyle: AppTypography.buttonDark,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
