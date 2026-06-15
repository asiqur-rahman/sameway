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
    this.validator,
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
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final field = validator != null
        ? TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textAlignVertical: TextAlignVertical.center,
            style: AppTypography.fieldValue.copyWith(height: 1.2),
            decoration: _inputDecoration(),
          )
        : TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            textAlignVertical: TextAlignVertical.center,
            style: AppTypography.fieldValue.copyWith(height: 1.2),
            decoration: _inputDecoration(),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.fieldLabel),
          const SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: SamewayDecorations.insetField(radius: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Text(icon!, style: const TextStyle(fontSize: 16, height: 1)),
                  const SizedBox(width: 10),
                ],
                Expanded(child: field),
              ],
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(helper!, style: AppTypography.caption),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
        hintText: hint,
        hintMaxLines: 1,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        hintStyle: AppTypography.fieldHint.copyWith(height: 1.2),
        errorStyle: AppTypography.caption.copyWith(color: Colors.red),
      );
}
