export 'app_colors.dart';
export 'app_fonts.dart';
export 'app_text_styles.dart';
export 'app_images.dart';
export 'app_strings.dart';
export 'app_theme.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';
import 'app_images.dart';
import 'app_strings.dart';
import 'app_theme.dart';

/// Unified access point for all application resources.
/// Example:
/// ```dart
/// final primaryColor = AppResources.colors.primary;
/// final title = AppResources.strings.appName;
/// final style = AppResources.styles.h1;
/// ```
class AppResources {
  AppResources._();

  static Type get colors => AppColors;
  static Type get fonts => AppFonts;
  static Type get styles => AppTextStyles;
  static Type get images => AppImages;
  static Type get strings => AppStrings;
  static Type get theme => AppTheme;
}

/// Short alias for AppResources (R.string, R.color, etc.)
typedef R = AppResources;
