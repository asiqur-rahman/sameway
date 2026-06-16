import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/api_exception.dart';
import 'package:sameway/core/theme/app_colors.dart';

enum SamewayBannerType { error, success, info, warning }

/// iOS-style floating banner — slides from the top, auto-dismisses, frosted card.
class SamewayBanner {
  SamewayBanner._();

  static OverlayEntry? _entry;
  static Timer? _timer;
  static void Function({
    required String message,
    required SamewayBannerType type,
    required Duration duration,
  })? _showViaHost;

  static void _registerHost(void Function({
    required String message,
    required SamewayBannerType type,
    required Duration duration,
  }) show) {
    _showViaHost = show;
  }

  static void _unregisterHost() {
    _showViaHost = null;
  }

  static void show(
    BuildContext context, {
    required String message,
    SamewayBannerType type = SamewayBannerType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay != null) {
      _present(overlay, message: message, type: type, duration: duration);
      return;
    }
    _showViaHost?.call(message: message, type: type, duration: duration);
  }

  static void showError(BuildContext context, Object message, {Duration? duration}) {
    show(
      context,
      message: formatError(message),
      type: SamewayBannerType.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: SamewayBannerType.success);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: SamewayBannerType.info);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: SamewayBannerType.warning);
  }

  static String formatError(Object error) {
    if (error is ApiException) return error.message;
    final raw = error.toString();
    const prefixes = ['Exception: ', 'ApiException: ', 'StateError: ', 'FormatException: '];
    for (final prefix in prefixes) {
      if (raw.startsWith(prefix)) return raw.substring(prefix.length);
    }
    if (raw.contains('SocketException') || raw.contains('Connection refused')) {
      return 'Could not reach the server. Check your connection and try again.';
    }
    if (raw.contains('Missing coordinates')) {
      return 'Set both locations on the map before searching.';
    }
    return raw;
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static void _present(
    OverlayState overlay, {
    required String message,
    required SamewayBannerType type,
    required Duration duration,
  }) {
    hide();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FloatingBanner(
        message: message,
        type: type,
        onDismiss: () {
          if (_entry == entry) hide();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, hide);
  }
}

class SamewayBannerHost extends StatefulWidget {
  const SamewayBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<SamewayBannerHost> createState() => _SamewayBannerHostState();
}

class _SamewayBannerHostState extends State<SamewayBannerHost> {
  @override
  void initState() {
    super.initState();
    SamewayBanner._registerHost(show);
  }

  @override
  void dispose() {
    SamewayBanner._unregisterHost();
    SamewayBanner.hide();
    super.dispose();
  }

  void show({
    required String message,
    required SamewayBannerType type,
    required Duration duration,
  }) {
    SamewayBanner._present(
      Overlay.of(context, rootOverlay: true),
      message: message,
      type: type,
      duration: duration,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FloatingBanner extends StatefulWidget {
  const _FloatingBanner({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final SamewayBannerType type;
  final VoidCallback onDismiss;

  @override
  State<_FloatingBanner> createState() => _FloatingBannerState();
}

class _FloatingBannerState extends State<_FloatingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  ({Color accent, Color bg, IconData icon}) get _style {
    return switch (widget.type) {
      SamewayBannerType.error => (
          accent: AppColors.error,
          bg: const Color(0xFFFFF1F2),
          icon: CupertinoIcons.exclamationmark_circle_fill,
        ),
      SamewayBannerType.success => (
          accent: AppColors.primary,
          bg: const Color(0xFFECFDF5),
          icon: CupertinoIcons.checkmark_circle_fill,
        ),
      SamewayBannerType.warning => (
          accent: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFFBEB),
          icon: CupertinoIcons.exclamationmark_triangle_fill,
        ),
      SamewayBannerType.info => (
          accent: AppColors.accentBlue,
          bg: const Color(0xFFEFF6FF),
          icon: CupertinoIcons.info_circle_fill,
        ),
    };
  }

  bool get _isCompactMessage {
    final text = widget.message.trim();
    return text.length <= 52 && !text.contains('\n');
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final top = MediaQuery.paddingOf(context).top + 8;
    final compact = _isCompactMessage;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
                  _dismiss();
                }
              },
              onTap: _dismiss,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: compact ? 360 : double.infinity,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: style.accent.withValues(alpha: 0.22)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: compact
                            ? _buildCompactContent(style)
                            : _buildExpandedContent(style),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent(({Color accent, Color bg, IconData icon}) style) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 40, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(style.icon, color: style.accent, size: 17),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _closeButton(),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(({Color accent, Color bg, IconData icon}) style) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(style.icon, color: style.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: Text(
                widget.message,
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          _closeButton(),
        ],
      ),
    );
  }

  Widget _closeButton() {
    return GestureDetector(
      onTap: _dismiss,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          CupertinoIcons.xmark,
          size: 16,
          color: AppColors.textMuted.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
