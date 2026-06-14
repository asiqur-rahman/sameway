import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/web_scaffold.dart';

class WebPostRideScreen extends StatelessWidget {
  WebPostRideScreen({super.key});

  final _fromController = TextEditingController(text: 'Uttara Sector 4, Dhaka');
  final _toController = TextEditingController(text: 'Motijheel, Dhaka');
  final _timeController = TextEditingController(text: '8:30 AM');
  final _seatsController = TextEditingController(text: '2');

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
                          controller: _fromController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SamewayTextField(
                          label: 'To',
                          icon: '🏢',
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
                          controller: _timeController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SamewayTextField(
                          label: 'Available seats',
                          controller: _seatsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SamewayPrimaryButton(
                    label: 'Post Ride',
                    backgroundColor: AppColors.primaryDark,
                    height: 49,
                    borderRadius: 12,
                    fontSize: 16,
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
