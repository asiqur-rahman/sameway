import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/chat_widgets.dart';
import 'package:sameway/core/widgets/sameway_bottom_nav.dart';
import 'package:sameway/core/widgets/sameway_loading.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDataStore.instance.refreshChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final store = AppDataStore.instance;
        final threads = store.chatThreads;
        final hasUnread = store.unreadChatCount > 0;
        final isLoading = store.isLoadingChats && !store.isRefreshingChats;

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
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => store.refreshChats(refresh: true),
                  child: isLoading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [ChatListSkeleton()],
                        )
                      : threads.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.28,
                                ),
                                Center(
                                  child: Text(
                                    'No messages yet.\nChat opens when a ride is confirmed.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
