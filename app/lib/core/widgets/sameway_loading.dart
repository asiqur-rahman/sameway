import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

/// Branded inline spinner.
class SamewayLoader extends StatelessWidget {
  const SamewayLoader({super.key, this.size = 28, this.strokeWidth = 2.5});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: AppColors.primary,
      ),
    );
  }
}

/// Pulsing placeholder block for skeleton layouts.
class SamewayShimmer extends StatefulWidget {
  const SamewayShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SamewayShimmer> createState() => _SamewayShimmerState();
}

class _SamewayShimmerState extends State<SamewayShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.45 + _controller.value * 0.55,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 12,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SamewayShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class RideListingSkeleton extends StatelessWidget {
  const RideListingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(height: 44, width: 44, radius: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 14, width: 120),
                    SizedBox(height: 8),
                    SkeletonBox(height: 12, width: 180),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          SkeletonBox(height: 12, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 12, width: 200),
          SizedBox(height: 14),
          SkeletonBox(height: 36, width: double.infinity, radius: 10),
        ],
      ),
    );
  }
}

class RideCardSkeleton extends StatelessWidget {
  const RideCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 22, width: 100, radius: 6),
          SizedBox(height: 12),
          SkeletonBox(height: 16, width: 220),
          SizedBox(height: 8),
          SkeletonBox(height: 13, width: 160),
        ],
      ),
    );
  }
}

class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: [
          SizedBox(height: 8),
          _ChatRowSkeleton(),
          _ChatRowSkeleton(),
          _ChatRowSkeleton(),
        ],
      ),
    );
  }
}

class _ChatRowSkeleton extends StatelessWidget {
  const _ChatRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SkeletonBox(height: 48, width: 48, radius: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: 120),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading / error / empty / content switcher with optional pull-to-refresh.
class AsyncContent extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.isLoading,
    this.isRefreshing = false,
    this.error,
    this.isEmpty = false,
    this.emptyMessage = 'Nothing here yet',
    this.emptyIcon = '📭',
    this.onRetry,
    this.onRefresh,
    this.skeleton,
    required this.child,
  });

  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool isEmpty;
  final String emptyMessage;
  final String emptyIcon;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final Widget? skeleton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading && !isRefreshing) {
      body = skeleton ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: SamewayLoader(),
            ),
          );
    } else if (error != null && !isRefreshing) {
      body = _ErrorView(message: error!, onRetry: onRetry);
    } else if (isEmpty) {
      body = _EmptyView(message: emptyMessage, icon: emptyIcon);
    } else {
      body = child;
    }

    if (onRefresh != null) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: onRefresh!,
        child: body is ScrollView || body is ListView
            ? body
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: MediaQuery.sizeOf(context).height * 0.25), body],
              ),
      );
    }

    return body;
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message, required this.icon});

  final String message;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Try again',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
