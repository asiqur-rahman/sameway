import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/chat_widgets.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final threads = AppDataStore.instance.chatThreads;
        final hasUnread = AppDataStore.instance.unreadChatCount > 0;

        return SamewayScreen(
          bottomNavigationBar: SamewayBottomNav(
            currentIndex: 2,
            chatUnread: hasUnread,
          ),
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
                child: threads.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet.\nRequest a ride to start chatting.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: threads.length,
                        separatorBuilder: (_, index) =>
                            const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final thread = threads[index];
                          return ChatListTile(
                            name: thread.peerName,
                            preview: thread.preview,
                            time: thread.previewTime,
                            unread: thread.unread,
                            onTap: () => context.push(
                              '${AppRoutes.chatConversation}?threadId=${thread.id}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
