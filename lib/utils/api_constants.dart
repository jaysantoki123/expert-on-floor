class ApiConstants {
   static const String GOOGLE_CLIENT_ID = "602850848367-tssnldslujlhkkei23iedefmp6pjvstk.apps.googleusercontent.com";
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web, or your machine's IP for physical devices
  static const String baseUrl = "http://10.128.144.56:5000/v1"; 

  static const String registerUrl = "$baseUrl/auth/register";
  static const String loginUrl = "$baseUrl/auth/login";
  static const String forgotPasswordUrl = "$baseUrl/auth/forgot-password";
  static const String verifyOtpUrl = "$baseUrl/auth/verify-otp";
  static const String resetPasswordUrl = "$baseUrl/auth/reset-password";
  static const String googleLoginUrl = "$baseUrl/auth/google";
  static const String expertsUrl = "$baseUrl/experts";
}

