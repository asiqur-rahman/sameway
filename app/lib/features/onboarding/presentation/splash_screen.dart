import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/widgets/sameway_loading.dart';
import 'package:sameway/core/widgets/splash_scene.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _waitForBootstrap();
  }

  Future<void> _waitForBootstrap() async {
    while (!AppSession.instance.isReady || !AppDataStore.instance.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _bootstrapped = true);

    final session = AppSession.instance;
    if (session.isLoggedIn) {
      final route = session.onboardingRouteForCurrentUser() ?? AppRoutes.home;
      context.go(route);
    }
  }

  void _goSignUp() {
    if (!_bootstrapped) return;
    if (AppSession.instance.isLoggedIn &&
        !AppSession.instance.currentUser!.onboardingComplete) {
      context.go(AppSession.instance.onboardingRouteForCurrentUser()!);
      return;
    }
    if (AppSession.instance.isLoggedIn) {
      context.go(AppRoutes.home);
      return;
    }
    context.push(AppRoutes.signUp);
  }

  void _goSignIn() {
    if (!_bootstrapped) return;
    if (AppSession.instance.isLoggedIn) {
      final route =
          AppSession.instance.onboardingRouteForCurrentUser() ?? AppRoutes.home;
      context.go(route);
      return;
    }
    context.push(AppRoutes.signIn);
  }

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
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: _bootstrapped ? 1 : 0.5,
              child: SplashBottomPanel(
                onGetStarted: _goSignUp,
                onSignIn: _goSignIn,
              ),
            ),
          ),
          if (!_bootstrapped)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 200,
              child: Center(child: SamewayLoader(size: 24)),
            ),
        ],
      ),
    );
  }
}
