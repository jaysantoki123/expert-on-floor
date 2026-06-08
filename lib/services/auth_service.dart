import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/api_constants.dart';
import '../logger_factory.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // IMPORTANT: Use the WEB CLIENT ID from Google Cloud Console
    serverClientId: ApiConstants.GOOGLE_CLIENT_ID,
  );

  // Login method
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          final Map<String, dynamic> data = responseBody['data'] ?? {};
          final user = UserModel.fromJson(data['user'] ?? {});

          // Store token and user data
          await _saveUserData(data['token'], data['refreshToken'], user);

          return user;
        } else {
          throw HttpException('Server returned an unexpected response format');
        }
      } else if (response.statusCode == 401) {
        throw HttpException('Invalid credentials');
      } else if (response.statusCode == 404) {
        throw HttpException('User not found');
      } else {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          throw HttpException(
            responseBody['message'] ?? 'Server error: ${response.statusCode}',
          );
        } else {
          throw HttpException('Server error: ${response.statusCode}');
        }
      }
    } on SocketException {
      throw HttpException(
        'Network error: Please check your internet connection',
      );
    } on http.ClientException {
      throw HttpException('Client error occurred');
    } catch (e) {
      rethrow;
    }
  }

  // Register method
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.registerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return;
      } else if (response.statusCode == 409) {
        throw HttpException('Email already registered');
      } else {
        // Check if the response is JSON
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          throw HttpException(
            responseBody['message'] ?? 'Server error: ${response.statusCode}',
          );
        } else {
          throw HttpException(
            'Server returned an unexpected response (Error ${response.statusCode})',
          );
        }
      }
    } on SocketException {
      throw HttpException(
        'Network error: Please check your internet connection',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Save user data to shared preferences
  Future<void> _saveUserData(
    String? token,
    String? refreshToken,
    UserModel user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('token', token);
    if (refreshToken != null)
      await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get stored user data
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Logout method
  Future<void> logout() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('user_data');
  }

  // Google Login
  Future<UserModel?> googleLogin() async {
    try {
      final _logger = AppLogger.create(topic: 'AuthService');
      _logger.i("Starting Google Login...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.i("Google Sign In cancelled by user.");
        return null;
      }

      _logger.i("Google User: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      _logger.i("ID Token: $idToken");
      _logger.i("Access Token: ${googleAuth.accessToken}");

      if (idToken == null) {
        throw HttpException('Failed to get ID Token from Google');
      }

      final response = await http
          .post(
            Uri.parse(ApiConstants.googleLoginUrl),
            headers: {'Content-Type': 'application/json'},
            // Backend expects "token" instead of "idToken"
            body: jsonEncode({'token': idToken}),
          )
          .timeout(const Duration(seconds: 15));

      _logger.i("Response Status: ${response.statusCode}");
      _logger.i("Response Body: ${response.body}");

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['success'] == true) {
          // Backend returns { success: true, data: { user, token, refreshToken } }
          final Map<String, dynamic> data = responseBody['data'] ?? {};
          final user = UserModel.fromJson(data['user'] ?? {});

          await _saveUserData(data['token'], data['refreshToken'], user);
          return user;

    
        } else {
          throw HttpException(responseBody['message'] ?? 'Google Login failed');
        }
      } else {
        throw HttpException('Server returned an unexpected response format');
      }
    } on SocketException {
      throw HttpException(
        'Network error: Please check your internet connection',
      );
    } catch (e) {
      print("Error during Google Login: $e");
      rethrow;
    }
  }

  // Forgot Password
  Future<String> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.forgotPasswordUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return responseBody['message'] ?? 'OTP sent successfully';
        } else {
          throw HttpException(responseBody['message'] ?? 'Failed to send OTP');
        }
      } else {
        throw HttpException(
          'Server returned an unexpected response (Error ${response.statusCode})',
        );
      }
    } on SocketException {
      throw HttpException(
        'Network error: Please check your internet connection',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.verifyOtpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return responseBody['message'] ?? 'OTP verified';
        } else {
          throw HttpException(responseBody['message'] ?? 'Invalid OTP');
        }
      } else {
        throw HttpException(
          'Server returned an unexpected response (Error ${response.statusCode})',
        );
      }
    } on SocketException {
      throw HttpException(
        'Network error: Please check your internet connection',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<String> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.resetPasswordUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return responseBody['message'] ?? 'Password reset successfully';
        } else {
          throw HttpException(
            responseBody['message'] ?? 'Failed to reset password',
          );
        }
      } else {
        throw HttpException(
          'Server returned an unexpected response (Error ${response.statusCode})',
        );
      }
    } on SocketException {
      throw HttpException(
        'Network error: Please check your internet connection',
      );
    } catch (e) {
      rethrow;
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
