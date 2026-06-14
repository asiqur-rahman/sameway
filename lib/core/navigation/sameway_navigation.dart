import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class SamewayNavigation {
  /// Pops when possible; otherwise navigates to [fallback].
  static void popOrGo(BuildContext context, {String? fallback}) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (fallback != null) {
      context.go(fallback);
    }
  }
}
