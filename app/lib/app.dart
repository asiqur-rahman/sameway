import 'package:flutter/material.dart';
import 'package:sameway/core/constants/app_brand.dart';
import 'package:sameway/core/theme/app_theme.dart';
import 'package:sameway/router/app_router.dart';

class SameWayApp extends StatelessWidget {
  const SameWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
