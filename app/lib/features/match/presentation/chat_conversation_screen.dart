import 'package:flutter/material.dart';
import 'package:sameway/core/navigation/sameway_navigation.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/chat_widgets.dart';
import 'package:sameway/core/widgets/sameway_loading.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppDataStore.instance.loadConversation(widget.threadId);
      await AppDataStore.instance.markChatRead(widget.threadId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final store = AppDataStore.instance;
        final thread = store.threadById(widget.threadId);
        final loadingMessages = store.isLoadingConversationFor(widget.threadId);

        if (thread == null && !loadingMessages) {
          return SamewayScreen(
            child: Center(
              child: Text(
                'Conversation not found',
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            ),
          );
        }

        final peerName = thread?.peerName ?? '…';
        final initial = peerName.isNotEmpty
            ? peerName.characters.first.toUpperCase()
            : '?';

        return SamewayScreen(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  8,
                  AppSpacing.screenHorizontal,
                  12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => SamewayNavigation.popOrGo(
                            context,
                            fallback: AppRoutes.chat,
                          ),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            initial,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                peerName,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Ride chat',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (thread != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('🚗', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                thread.rideContext,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: loadingMessages
                    ? const Center(child: SamewayLoader())
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                        children: [
                          if (thread != null)
                            for (final message in thread.messages)
                              ChatBubble(
                                message: message.text,
                                isMine: message.isMine,
                                time: message.timeLabel,
                              ),
                        ],
                      ),
              ),
              ChatInputBar(
                isSending: store.isSendingMessage,
                onSendAsync: (text) =>
                    store.sendChatMessage(widget.threadId, text),
              ),
            ],
          ),
        );
      },
    );
  }
}
