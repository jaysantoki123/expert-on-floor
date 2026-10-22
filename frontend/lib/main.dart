  import 'package:flutter/material.dart';
  import 'package:flutter_application_1/screens/splash_screen.dart';
  import 'package:provider/provider.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'core/theme/app_colors.dart';
  import 'providers/auth_provider.dart';
  import 'providers/expert_provider.dart';
  import 'providers/roadmap_provider.dart';
  import 'providers/booking_provider.dart';
  import 'providers/chat_provider.dart';
  import 'providers/notification_provider.dart';
  import 'services/fcm_service.dart';
  import 'firebase_options.dart';
import 'package:flutter_application_1/utils/api_constants.dart';


  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    ApiConstants.logDartDefines();

    // Firebase Messaging must not be accessed until the default Firebase app
    // has been created.  Do not swallow this error: continuing here would make
    // `FirebaseMessaging.instance` fail with `[core/no-app]` later.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    // Initialize push notification service
    await FCMService().initialize(navigatorKey);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
          ChangeNotifierProvider(create: (_) => ExpertProvider()),
          ChangeNotifierProvider(create: (_) => RoadmapProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: ExpertMentorApp(navigatorKey: navigatorKey),
      ),

    );
  } 

  class ExpertMentorApp extends StatelessWidget {
    final GlobalKey<NavigatorState> navigatorKey;

    const ExpertMentorApp({super.key, required this.navigatorKey});   

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'ExpertMentor',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.white,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        home: const SplashScreen(),
      );
    }
  }
