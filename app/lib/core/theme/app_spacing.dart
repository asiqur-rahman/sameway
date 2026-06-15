/// Figma mobile frame width — all spacing derived from 390px artboard.
abstract final class AppSpacing {
  static const screenHorizontal = 20.0;
  static const cardPadding = 16.0;

  /// Onboarding body below [MobilePageHeader] — matches wireframe `padding: 16px 20px 28px`.
  static const onboardingBodyTop = 16.0;
  static const onboardingBodyBottom = 28.0;

  /// Sign-up screen uses slightly wider inset (`28px 22px`).
  static const signUpHorizontal = 22.0;
  static const signUpTop = 28.0;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 14.0;
  static const xl = 16.0;
  static const logo = 24.0;
}
