import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';

class SamewayShell extends StatelessWidget {
  const SamewayShell({
    super.key,
    required this.child,
    required this.navIndex,
    this.showBottomNav = true,
  });

  final Widget child;
  final int navIndex;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar:
          showBottomNav ? SamewayBottomNav(currentIndex: navIndex) : null,
    );
  }
}
