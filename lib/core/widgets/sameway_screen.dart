import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/sameway_status_bar.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SafeArea(bottom: false, child: SamewayStatusBar()),
          Expanded(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
