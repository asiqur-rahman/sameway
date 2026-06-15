import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';

/// Shows the 3 required work verification steps.
class WorkVerificationSteps extends StatelessWidget {
  const WorkVerificationSteps({
    super.key,
    required this.currentStep,
    this.emailDone = false,
    this.officeDone = false,
    this.employeeIdDone = false,
  });

  /// 1 = work email, 2 = office on map, 3 = employee ID
  final int currentStep;
  final bool emailDone;
  final bool officeDone;
  final bool employeeIdDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepChip(
          step: 1,
          label: 'Work email',
          done: emailDone || currentStep > 1,
          active: currentStep == 1,
        ),
        const _StepLine(),
        _StepChip(
          step: 2,
          label: 'Office map',
          done: officeDone || currentStep > 2,
          active: currentStep == 2,
        ),
        const _StepLine(),
        _StepChip(
          step: 3,
          label: 'Employee ID',
          done: employeeIdDone,
          active: currentStep == 3,
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: AppColors.border,
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.step,
    required this.label,
    required this.done,
    required this.active,
  });

  final int step;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.primary
        : active
            ? AppColors.primaryDark
            : AppColors.textMuted;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: active || done ? AppColors.primary : AppColors.border,
              width: active ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '$step',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
