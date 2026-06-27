import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static const String googleClientId = "602850848367-tssnldslujlhkkei23iedefmp6pjvstk.apps.googleusercontent.com";

  // Set this to your PC IP when testing on a physical mobile device.
<<<<<<< Updated upstream
  static const String physicalDeviceHost = 'http://10.128.144.56:5000/v1';
=======
  static const String physicalDeviceHost = 'http://localhost:5000/v1';
>>>>>>> Stashed changes
  static const bool useAndroidEmulatorHost = true;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/v1';
    }
    if (Platform.isAndroid) {
      // Use 10.0.2.2 for Android emulator, or a physical device host if needed.
      return useAndroidEmulatorHost
          ? 'http://10.128.144.56:5000/v1'
          : physicalDeviceHost;
    }
    if (Platform.isIOS) {
      return 'http://localhost:5000/v1';
    }
    return physicalDeviceHost;
  }

  static String get socketUrl => baseUrl.replaceAll('/v1', '');

  static String get registerUrl => '$baseUrl/auth/register';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get forgotPasswordUrl => '$baseUrl/auth/forgot-password';
  static String get verifyOtpUrl => '$baseUrl/auth/verify-otp';
  static String get resetPasswordUrl => '$baseUrl/auth/reset-password';
  static String get googleLoginUrl => '$baseUrl/auth/google';
  static String get expertsUrl => '$baseUrl/experts';
}

