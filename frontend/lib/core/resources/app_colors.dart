import 'package:flutter/material.dart';

/// Centralized application color palette.
/// Controls all primary, secondary, neutral, semantic and surface colors.
class AppColors {
  AppColors._();

  // ── Primary Brand Colors ────────────────────────────
  /// Main vibrant green
  static const Color primary = Color(0xFF009D45);

  /// Dark emerald green for pressed states & gradient anchors
  static const Color primaryDark = Color(0xFF007A35);

  /// Light mint green tint for chips, badges, and active states
  static const Color primarySoft = Color(0xFFEAF7EF);

  /// Ultra-light primary background tint
  static const Color primaryExtraLight = Color(0xFFF3FAF5);

  // ── Secondary & Accent Colors ───────────────────────
  static const Color secondary = Color(0xFF0284C7);
  static const Color secondaryDark = Color(0xFF0369A1);
  static const Color secondarySoft = Color(0xFFE0F2FE);

  static const Color accent = Color(0xFF6366F1);
  static const Color accentSoft = Color(0xFFEEF2FF);

  // ── Neutral & Text Shades ───────────────────────────
  /// Near-black high-emphasis text
  static const Color ink = Color(0xFF20232A);

  /// Medium-dark text for sub-headers
  static const Color inkMedium = Color(0xFF374151);

  /// Soft light-gray for card backgrounds & pill containers
  static const Color inkSoft = Color(0xFFF5F7F6);

  /// Medium-gray for body secondary text and icons
  static const Color muted = Color(0xFF7C8590);

  /// Light muted text for placeholders & hints
  static const Color hint = Color(0xFF9CA3AF);

  // ── Borders & Surfaces ──────────────────────────────
  /// Subtle border gray
  static const Color line = Color(0xFFE7ECE8);

  /// Ultra-light border
  static const Color borderSubtle = Color(0xFFF1F5F2);

  /// Off-white textfield background
  static const Color field = Color(0xFFFBFCFB);

  /// Pure white surface
  static const Color white = Color(0xFFFFFFFF);

  /// Default scaffold background
  static const Color background = Color(0xFFF9FAFB);

  /// Secondary scaffold background
  static const Color backgroundSecondary = Color(0xFFF4F6F4);

  // ── Semantic Status Colors ──────────────────────────
  /// Success green
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);

  /// Danger / Error red
  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFFEBEE);
  static const Color errorBorder = Color(0xFFFECACA);

  /// Warning / Alert amber
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);

  /// Info blue
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);

  // ── Gradients ───────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF009D45), Color(0xFF007A35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
