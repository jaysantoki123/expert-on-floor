import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;

class ApiConstants {
  // May be overridden for another OAuth application at build time.
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '602850848367-tssnldslujlhkkei23iedefmp6pjvstk.apps.googleusercontent.com',
  );

  // A physical device must be told how to reach the API at build time.
  static const String _baseUrlFromEnv = "http://10.253.53.56:5000/v1";

  static const String _iosFirebaseApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const String _legacyWebFirebaseApiKey = String.fromEnvironment(
    '602850848367-tssnldslujlhkkei23iedefmp6pjvstk.apps.googleusercontent.com',
  );

  /// Prints the compile-time configuration used by this app in debug builds.
  /// Dart does not expose an API to enumerate arbitrary `--dart-define` keys,
  /// so this lists every define currently read by the frontend explicitly.
  static void logDartDefines() {
    if (!kDebugMode) return;

    debugPrint('--- Dart defines ---');
    debugPrint('API_BASE_URL=${_display(_baseUrlFromEnv)}');
    debugPrint('GOOGLE_CLIENT_ID=${_display(googleClientId)}');
    debugPrint('FIREBASE_IOS_API_KEY=${_redact(_iosFirebaseApiKey)}');
    debugPrint(
      'legacy Firebase web API-key define=${_redact(_legacyWebFirebaseApiKey)}',
    );
    debugPrint('--------------------');
  }

  static String _display(String value) =>
      value.isEmpty ? '<not set>' : value;

  static String _redact(String value) {
    if (value.isEmpty) return '<not set>';
    if (value.length <= 8) return '<configured>';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static const bool useAndroidEmulatorHost = false;

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }

    if (kIsWeb) {
      return 'http://localhost:5000/v1';
    }
    if (Platform.isAndroid) {
      if (useAndroidEmulatorHost) {
        return 'http://10.0.2.2:5000/v1';
      }

      throw StateError(
        'API_BASE_URL not set. Run with: --dart-define=API_BASE_URL=https://<your-server>:5000/v1',
      );
    }
    if (Platform.isIOS) {
      return 'http://localhost:5000/v1';
    }
    // Desktop or unknown: require explicit configuration
    throw StateError(
      'API_BASE_URL not set. Run with: --dart-define=API_BASE_URL=https://<your-server>:5000/v1',
    );
  }

  static String get registerUrl => '$baseUrl/auth/register';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get forgotPasswordUrl => '$baseUrl/auth/forgot-password';
  static String get verifyOtpUrl => '$baseUrl/auth/verify-otp';
  static String get resetPasswordUrl => '$baseUrl/auth/reset-password';
  static String get googleLoginUrl => '$baseUrl/auth/google';
  static String get logoutUrl => '$baseUrl/auth/logout';
  static String get expertsUrl => '$baseUrl/experts';
  static String get generateRoadmapUrl => '$baseUrl/roadmap/generate';
  static String get myRoadmapUrl => '$baseUrl/roadmap/my-roadmap';
  static String getPhaseDetailUrl(int phaseId) => '$baseUrl/roadmap/phase/$phaseId';
  static String getCompletePhaseUrl(int phaseId) => '$baseUrl/roadmap/phase/$phaseId';
  static String get createBookingUrl => '$baseUrl/bookings';
  static String get myBookingsUrl => '$baseUrl/bookings';
  static String get sessionHistoryUrl => '$baseUrl/bookings/session-history';
  static String get verifyPaymentUrl => '$baseUrl/payments/verify';
  static String get createOrderUrl => '$baseUrl/payments/create-order';
  static String get paymentHistoryUrl => '$baseUrl/payments/history';
  static String cancelBookingUrl(int id) => '$baseUrl/bookings/$id/cancel';
  static String acceptBookingUrl(int id) => '$baseUrl/bookings/$id/accept';
  static String rejectBookingUrl(int id) => '$baseUrl/bookings/$id/reject';
  static String get communityPostsUrl => '$baseUrl/community/posts';
  static String get communityTagsUrl => '$baseUrl/community/tags';
  static String getPostAnswersUrl(int id) => '$baseUrl/community/posts/$id/answers';
  static String getLikePostUrl(int id) => '$baseUrl/community/posts/$id/like';
  static String getPostDetailUrl(int id) => '$baseUrl/community/posts/$id';

  // Notifications & Likes
  static String get notificationsUrl => '$baseUrl/notifications';
  static String get readAllNotificationsUrl => '$baseUrl/notifications/read-all';
  static String getLikeAnswerUrl(int id) => '$baseUrl/community/answers/$id/like';
  static String getLikeReviewUrl(int id) => '$baseUrl/experts/reviews/$id/like';
  static String get myReviewsUrl => '$baseUrl/experts/my-reviews';
  static String submitReviewUrl(int expertId) => '$baseUrl/experts/$expertId/reviews';

  // Chat APIs
  static String get socketUrl => baseUrl.replaceAll('/v1', '');
  static String get conversationsUrl => '$baseUrl/conversations';
  static String conversationMessagesUrl(dynamic id) => '$baseUrl/conversations/$id/messages';
  static String get sendMessageUrl => '$baseUrl/messages';
}

