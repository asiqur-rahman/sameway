import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';

class SamewayScreen extends StatelessWidget {
  const SamewayScreen({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.padding,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
