import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/widgets/splash_scene.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040C07),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashScene(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SplashBottomPanel(
              onGetStarted: () {
                if (AppSession.instance.isLoggedIn &&
                    !AppSession.instance.currentUser!.onboardingComplete) {
                  context.go(
                    AppSession.instance.onboardingRouteForCurrentUser()!,
                  );
                  return;
                }
                if (AppSession.instance.isLoggedIn) {
                  context.go(AppRoutes.home);
                  return;
                }
                context.push(AppRoutes.signUp);
              },
              onSignIn: () {
                if (AppSession.instance.isLoggedIn) {
                  final route =
                      AppSession.instance.onboardingRouteForCurrentUser() ??
                          AppRoutes.home;
                  context.go(route);
                  return;
                }
                context.push(AppRoutes.signIn);
              },
            ),
          ),
        ],
      ),
    );
  }
}
