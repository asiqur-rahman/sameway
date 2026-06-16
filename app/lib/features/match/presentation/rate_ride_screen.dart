import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/api_exception.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

/// Screen shown after a ride is completed.
///
/// Query parameters passed via GoRouter extra:
///   rideId       — the completed ride ID
///   targetUserId — the driver (or rider) being reviewed
///   targetName   — display name of the person being reviewed
///   isDriver     — whether the current user is rating a driver
class RateRideScreen extends StatefulWidget {
  const RateRideScreen({
    super.key,
    required this.rideId,
    required this.targetUserId,
    required this.targetName,
    this.isDriver = true,
  });

  final String rideId;
  final String targetUserId;
  final String targetName;
  final bool isDriver;

  @override
  State<RateRideScreen> createState() => _RateRideScreenState();
}

class _RateRideScreenState extends State<RateRideScreen> {
  int _rating = 5;
  final _commentCtl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await RidesRepository.instance.submitReview(
        rideId: widget.rideId,
        targetUserId: widget.targetUserId,
        rating: _rating,
        comment: _commentCtl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      SamewayBanner.showError(context, e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      SamewayBanner.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: _submitted ? _buildDone() : _buildForm(),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✅', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Review submitted!',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Thanks — your review helps build trust in the community.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final role = widget.isDriver ? 'driver' : 'rider';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Rate your ride',
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 6),
        Text(
          'How was your ride with ${widget.targetName}?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 32),

        // Star selector
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? const Color(0xFFF59E0B) : AppColors.border,
                    size: 42,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _ratingLabel(_rating),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ratingColor(_rating),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Comment field
        Text(
          'Comment (optional)',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _commentCtl,
            maxLines: 4,
            maxLength: 300,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              hintText:
                  'Tell other riders about your experience with this $role…',
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              counterStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 49,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Submit review',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _ratingLabel(int r) => switch (r) {
        1 => 'Very poor',
        2 => 'Poor',
        3 => 'Okay',
        4 => 'Good',
        _ => 'Excellent',
      };

  Color _ratingColor(int r) => r >= 4
      ? AppColors.primary
      : r == 3
          ? const Color(0xFFF59E0B)
          : AppColors.error;
}
