import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Web/Backend OAuth 2.0 Client ID (configure via: --dart-define=GOOGLE_CLIENT_ID=...)
  static const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  // Base URL from environment, with fallback for local development
  // For production/staging, always pass via: --dart-define=API_BASE_URL=https://your-domain.com/v1
  static String get _baseUrlFromEnv => const String.fromEnvironment('API_BASE_URL');

  // Physical device testing: override via --dart-define=API_BASE_URL=https://<your-ip-or-domain>:5000/v1
  // Do NOT hardcode private IPs — they leak internal network topology.
  static const bool useAndroidEmulatorHost = false;

  static String get baseUrl {
    // If provided via --dart-define, use it (should be https:// in production)
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }
    
    // Local development fallbacks — HTTP is acceptable only for localhost
    if (kIsWeb) {
      return 'http://localhost:5000/v1';
    }
    if (Platform.isAndroid) {
      if (useAndroidEmulatorHost) {
        return 'http://10.0.2.2:5000/v1';
      }
      // Physical device: must be configured via --dart-define=API_BASE_URL
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

