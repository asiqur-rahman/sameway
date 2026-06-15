import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_typography.dart';

class SamewayTextField extends StatelessWidget {
  const SamewayTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.helper,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final String? hint;
  final String? icon;
  final String? helper;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: 5),
        Container(
          height: 47,
          decoration: SamewayDecorations.insetField(radius: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 16, height: 1)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  onTap: onTap,
                  textAlignVertical: TextAlignVertical.center,
                  style: AppTypography.fieldValue.copyWith(height: 1.2),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintMaxLines: 1,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: AppTypography.fieldHint.copyWith(height: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 5),
          Text(helper!, style: AppTypography.caption),
        ],
      ],
    );
  }
}
