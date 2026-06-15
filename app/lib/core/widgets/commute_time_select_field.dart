import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/utils/commute_time_format.dart';

/// Tappable leave-by / arrive-by field that opens the system time picker.
class CommuteTimeSelectField extends StatelessWidget {
  const CommuteTimeSelectField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onSelected,
    this.initialTime,
  });

  final String label;
  final String icon;
  final TimeOfDay? value;
  final String placeholder;
  final ValueChanged<TimeOfDay> onSelected;
  final TimeOfDay? initialTime;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? initialTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final display = hasValue ? CommuteTimeFormat.format(value!) : placeholder;

    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.sectionAccent(color: AppColors.textMuted),
                  ),
                  Text(
                    display,
                    style: hasValue
                        ? AppTypography.dateTimeValue
                        : AppTypography.dateTimeValue.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w400,
                          ),
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
