/// Centralized image assets and fallback URLs.
/// Keeps asset paths and remote fallbacks manageable from a single source of truth.
class AppImages {
  AppImages._();

  // ── Asset Path Base ─────────────────────────────────
  static const String _basePath = 'assets/images';
  static const String _iconsPath = 'assets/icons';

  // ── Local Asset Images (mapped in pubspec when provided) ──
  static const String logo = '$_basePath/logo.png';
  static const String logoSvg = '$_basePath/logo.svg';
  static const String splashBackground = '$_basePath/splash_bg.png';
  static const String onboarding1 = '$_basePath/onboarding_1.png';
  static const String onboarding2 = '$_basePath/onboarding_2.png';
  static const String onboarding3 = '$_basePath/onboarding_3.png';

  // ── Icons ───────────────────────────────────────────
  static const String googleIcon = '$_iconsPath/google.svg';
  static const String razorpayIcon = '$_iconsPath/razorpay.png';

  // ── Network Fallback Placeholders ───────────────────
  /// High-reliability fallback avatar for learners
  static const String defaultUserAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

  /// High-reliability fallback avatar for male expert
  static const String defaultExpertAvatarMale =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80';

  /// High-reliability fallback avatar for female expert
  static const String defaultExpertAvatarFemale =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80';

  /// General expert fallback image
  static const String defaultExpertPlaceholder =
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80';

  /// Default banner/cover placeholder
  static const String defaultBanner =
      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=1200&q=80';

  /// Empty state illustration placeholder
  static const String emptyState =
      'https://images.unsplash.com/photo-1584824486509-112e4181ff6b?auto=format&fit=crop&w=400&q=80';
}
