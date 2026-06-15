import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.time,
  });

  final String message;
  final bool isMine;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: AppColors.border),
          boxShadow: isMine
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isMine ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                time!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isMine
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.onSend,
    this.onSendAsync,
    this.isSending = false,
  });

  final ValueChanged<String>? onSend;
  final Future<void> Function(String)? onSendAsync;
  final bool isSending;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    if (widget.onSendAsync != null) {
      await widget.onSendAsync!(text);
    } else {
      widget.onSend?.call(text);
    }
    _controller.clear();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty && !widget.isSending;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: canSend ? () => _submit() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: canSend ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: widget.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: canSend ? Colors.white : AppColors.textMuted,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.name,
    required this.preview,
    required this.time,
    this.unread = false,
    this.onTap,
  });

  final String name;
  final String preview;
  final String time;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 4,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Text(
          name.characters.first,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: unread ? AppColors.textSecondary : AppColors.textMuted,
          fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: unread ? AppColors.primary : AppColors.textMuted,
              fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (unread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
