import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/chat_widgets.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      bottomNavigationBar: const SamewayBottomNav(currentIndex: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'Messages',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ChatListTile(
                  name: 'Karim Rahman',
                  preview: 'I\'ll be at the pickup point at 8:25',
                  time: '9:12 AM',
                  unread: true,
                  onTap: () => context.go(AppRoutes.chatConversation),
                ),
                const Divider(height: 1, color: AppColors.border),
                ChatListTile(
                  name: 'Sadia Khan',
                  preview: 'Thanks for the ride yesterday!',
                  time: 'Yesterday',
                  onTap: () => context.go(AppRoutes.chatConversation),
                ),
                const Divider(height: 1, color: AppColors.border),
                ChatListTile(
                  name: 'Tanvir Hossain',
                  preview: 'Can we split the toll cost?',
                  time: 'Mon',
                  onTap: () => context.go(AppRoutes.chatConversation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
