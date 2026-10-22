import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../screens/learner/my_bookings_screen.dart';
import '../screens/learner/conversations_screen.dart';
import '../firebase_options.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🔔 Background FCM message received: ${message.messageId}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final _secureStorage = SecureStorage();
  final _apiClient = ApiClient();

  GlobalKey<NavigatorState>? _navigatorKey;

  // Initialize Firebase Messaging & Local Notifications
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    // 1. Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Initialize local notifications for foreground alerts
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // 3. Request permissions
    await requestPermissions();

    // 4. Configure foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Setup message listeners
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);

    // 6. Handle app opened from terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleDeepLinking(initialMessage.data);
    }

    // 7. Setup token refresh listener
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('🔔 FCM token refreshed.');
      sendTokenToBackend(newToken);
    });

    debugPrint('🔔 FCMService initialized successfully.');
  }

  // Request permissions for Android/iOS
  Future<void> requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('🔔 FCM User notification permission status: ${settings.authorizationStatus}');
  }

  // Get current device token
  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      debugPrint('🔔 FCM Device Token retrieved.');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // Send the token to the Node.js backend
  Future<void> sendTokenToBackend(String token) async {
    try {
      final jwtToken = await _secureStorage.getToken();
      if (jwtToken == null) {
        debugPrint('🔔 Postponing token upload: user not authenticated');
        return;
      }

      final relativeUrl = '/auth/fcm-token';
      final response = await _apiClient.post(
        relativeUrl,
        body: {'fcmToken': token},
      );

      if (response.statusCode == 200) {
        debugPrint('🔔 FCM token synced with backend.');
      } else {
        debugPrint('❌ Failed to sync FCM token: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM token to backend: $e');
    }
  }

  // Handle message received while app is in foreground
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Foreground FCM Message: ${message.notification?.title}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'expert_mentor_notifications',
        'ExpertMentor Alerts',
        channelDescription: 'Main notification channel for booking events',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: jsonEncode(message.data),
      );
    }
  }

  // Handle local notification tap in foreground
  void _onLocalNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleDeepLinking(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Handle message tapped while app is in background
  void _onNotificationOpenedApp(RemoteMessage message) {
    debugPrint('🔔 Notification opened app: ${message.messageId}');
    _handleDeepLinking(message.data);
  }

  // Navigate to appropriate screen based on payload type
  void _handleDeepLinking(Map<String, dynamic> data) {
    if (_navigatorKey == null) {
      debugPrint('❌ FCMService: Navigator key is not set, deep link cancelled.');
      return;
    }

    final String type = data['type'] ?? '';
    debugPrint('🔔 Deep linking type: $type');

    if (type == 'new_message') {
      _navigatorKey!.currentState?.push(
        MaterialPageRoute(builder: (_) => const ConversationsScreen()),
      );
    } else {
      // Default to My Bookings Screen for booking confirmations, reminders, cancellations
      _navigatorKey!.currentState?.push(
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      );
    }
  }
}
