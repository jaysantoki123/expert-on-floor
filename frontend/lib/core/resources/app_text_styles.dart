import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// Pre-composed text styles following the design system hierarchy.
class AppTextStyles {
  AppTextStyles._();

  // ── Display & Hero Headings ─────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeDisplayLarge,
    fontWeight: AppFonts.extraBold,
    color: AppColors.ink,
    letterSpacing: AppFonts.spacingTight,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeDisplayMedium,
    fontWeight: AppFonts.extraBold,
    color: AppColors.ink,
    letterSpacing: AppFonts.spacingTight,
    height: 1.25,
  );

  // ── Standard Headings ───────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeHeading1,
    fontWeight: AppFonts.bold,
    color: AppColors.ink,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeHeading2,
    fontWeight: AppFonts.bold,
    color: AppColors.ink,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeHeading3,
    fontWeight: AppFonts.semiBold,
    color: AppColors.ink,
    height: 1.35,
  );

  // ── Titles & Card Headers ───────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeTitle,
    fontWeight: AppFonts.bold,
    color: AppColors.ink,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeTitle,
    fontWeight: AppFonts.semiBold,
    color: AppColors.ink,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodyLarge,
    fontWeight: AppFonts.semiBold,
    color: AppColors.ink,
  );

  // ── Body Text ───────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodyLarge,
    fontWeight: AppFonts.regular,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodyMedium,
    fontWeight: AppFonts.regular,
    color: AppColors.ink,
    height: 1.45,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodyMedium,
    fontWeight: AppFonts.regular,
    color: AppColors.muted,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodySmall,
    fontWeight: AppFonts.regular,
    color: AppColors.muted,
    height: 1.4,
  );

  // ── Buttons & Labels ────────────────────────────────
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeTitle,
    fontWeight: AppFonts.bold,
    color: AppColors.white,
    letterSpacing: AppFonts.spacingNormal,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodyMedium,
    fontWeight: AppFonts.semiBold,
    color: AppColors.white,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeBodySmall,
    fontWeight: AppFonts.semiBold,
    color: AppColors.inkMedium,
  );

  // ── Captions & Badges ───────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeCaption,
    fontWeight: AppFonts.regular,
    color: AppColors.muted,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeCaption,
    fontWeight: AppFonts.bold,
    color: AppColors.ink,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: AppFonts.fontFamily,
    fontSize: AppFonts.sizeTiny,
    fontWeight: AppFonts.bold,
    letterSpacing: AppFonts.spacingWide,
  );
}
