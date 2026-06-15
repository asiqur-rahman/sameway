import 'package:flutter/material.dart';
import 'package:sameway/core/theme/app_theme.dart';
import 'package:sameway/router/app_router.dart';

class SameWayApp extends StatelessWidget {
  const SameWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SameWay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
