import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_elevation.dart';
import 'package:sameway/core/theme/app_typography.dart';

class SamewayBottomNav extends StatelessWidget {
  const SamewayBottomNav({
    super.key,
    required this.currentIndex,
    this.chatUnread = false,
  });

  final int currentIndex;
  final bool chatUnread;

  static const _items = [
    _NavItem(label: 'Home', route: '/home', icon: Icons.home_rounded),
    _NavItem(label: 'Rides', route: '/rides', icon: Icons.directions_car_rounded),
    _NavItem(label: 'Chat', route: '/chat', icon: Icons.chat_bubble_outline_rounded),
    _NavItem(label: 'Profile', route: '/profile', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.navBar,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              final showBadge = index == 2 && chatUnread && !selected;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(item.route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 54,
                            height: 30,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.20)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: selected ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                          if (showBadge)
                            Positioned(
                              right: 10,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surface, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTypography.navLabel(selected: selected),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}
