import 'package:flutter/material.dart';

/// Centralized font families, weights, and sizes for consistent typography.
class AppFonts {
  AppFonts._();

  // ── Font Family ─────────────────────────────────────
  /// Primary font family used across the application
  static const String fontFamily = 'Roboto';

  /// Optional secondary display font (can be configured in pubspec)
  static const String fontFamilyDisplay = 'Roboto';

  // ── Font Weights ────────────────────────────────────
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ── Font Sizes ──────────────────────────────────────
  static const double sizeDisplayLarge = 34.0;
  static const double sizeDisplayMedium = 28.0;
  static const double sizeHeading1 = 24.0;
  static const double sizeHeading2 = 20.0;
  static const double sizeHeading3 = 18.0;
  static const double sizeTitle = 16.0;
  static const double sizeBodyLarge = 15.0;
  static const double sizeBodyMedium = 14.0;
  static const double sizeBodySmall = 13.0;
  static const double sizeCaption = 12.0;
  static const double sizeTiny = 10.0;

  // ── Letter Spacing ──────────────────────────────────
  static const double spacingTight = -0.5;
  static const double spacingNormal = 0.0;
  static const double spacingWide = 0.5;
  static const double spacingExtraWide = 1.0;
}
