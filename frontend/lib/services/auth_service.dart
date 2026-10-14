import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../utils/api_constants.dart';
import '../logger_factory.dart';

class AuthService {
  final _logger = AppLogger.create(topic: 'AuthService');
  final _apiClient = ApiClient();
  final _secureStorage = SecureStorage();
  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: ApiConstants.googleClientId,
  );

  // Login method
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginUrl.replaceFirst(ApiConstants.baseUrl, ''),
        body: {'email': email, 'password': password},
      );

      final data = _parseSuccessResponse(response);
      final user = UserModel.fromJson(data['user'] ?? {});

      await _saveAuthData(
        token: data['token'],
        refreshToken: data['refreshToken'],
        user: user,
      );

      return user;
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Login failed: $e');
    }
  }

  // Register method
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.registerUrl.replaceFirst(ApiConstants.baseUrl, ''),
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
          'role': role,
        },
      );

      _parseSuccessResponse(response);
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Registration failed: $e');
    }
  }

  // Save auth data to secure storage
  Future<void> _saveAuthData({
    required String? token,
    required String? refreshToken,
    required UserModel user,
  }) async {
    if (token != null) {
      await _secureStorage.saveToken(token);
    }
    if (refreshToken != null) {
      await _secureStorage.saveRefreshToken(refreshToken);
    }
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  // Get stored user data
  Future<UserModel?> getUserData() async {
    final userData = await _secureStorage.getUserData();
    if (userData != null) {
      try {
        final map = jsonDecode(userData) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      } catch (e) {
        _logger.e('Failed to parse user data: $e');
        return null;
      }
    }
    return null;
  }

  // Logout method
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _apiClient.post(
          ApiConstants.logoutUrl.replaceFirst(ApiConstants.baseUrl, ''),
        );
      }
    } catch (_) {
      // Ignore API errors, proceed with local logout
    } finally {
      await _googleSignIn.signOut();
      await _secureStorage.clearAuth();
    }
  }

  // Google Login
  Future<UserModel?> googleLogin() async {
    try {
      _logger.i('Starting Google Login...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.i('Google Sign In cancelled by user.');
        return null;
      }

      _logger.i('Google Sign In successful');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      _logger.i('Google auth tokens obtained');

      if (idToken == null) {
        throw AuthenticationException('Failed to get ID Token from Google');
      }

      final response = await _apiClient.post(
        ApiConstants.googleLoginUrl.replaceFirst(ApiConstants.baseUrl, ''),
        body: {'token': idToken},
      );

      _logger.i('Google login API response received');

      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        final Map<String, dynamic> data = responseBody['data'] ?? {};
        final user = UserModel.fromJson(data['user'] ?? {});

        await _saveAuthData(
          token: data['token'],
          refreshToken: data['refreshToken'],
          user: user,
        );
        return user;
      } else {
        throw AuthenticationException(responseBody['message'] ?? 'Google Login failed');
      }
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } on AppException {
      rethrow;
    } catch (e) {
      _logger.e('Error during Google Login: $e');
      rethrow;
    }
  }

  // Forgot Password
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPasswordUrl.replaceFirst(ApiConstants.baseUrl, ''),
        body: {'email': email},
      );

      final data = _parseSuccessResponse(response);
      return data['message'] ?? 'OTP sent successfully';
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Failed to send OTP: $e');
    }
  }

  // Verify OTP
  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtpUrl.replaceFirst(ApiConstants.baseUrl, ''),
        body: {'email': email, 'otp': otp},
      );

      final data = _parseSuccessResponse(response);
      return data['message'] ?? 'OTP verified';
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('OTP verification failed: $e');
    }
  }

  // Reset Password
  Future<String> resetPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPasswordUrl.replaceFirst(ApiConstants.baseUrl, ''),
        body: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      final data = _parseSuccessResponse(response);
      return data['message'] ?? 'Password reset successfully';
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Password reset failed: $e');
    }
  }

  // Update Profile
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'phone': phone,
      };
      if (avatar != null) body['avatar'] = avatar;

      final response = await _apiClient.put(
        '/auth/me',
        body: body,
      );

      final data = _parseSuccessResponse(response);
      final updatedUser = UserModel.fromJson(data);

      // Update stored user data
      final token = await _secureStorage.getToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      await _saveAuthData(
        token: token,
        refreshToken: refreshToken,
        user: updatedUser,
      );

      return updatedUser;
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Profile update failed: $e');
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.put(
        '/auth/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Password change failed: $e');
    }
  }

  // Get fresh profile from backend
  Future<UserModel> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      final data = _parseSuccessResponse(response);
      final user = UserModel.fromJson(data);

      // Update stored user data with fresh data
      final token = await _secureStorage.getToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      await _saveAuthData(
        token: token,
        refreshToken: refreshToken,
        user: user,
      );

      return user;
    } on AppException {
      rethrow;
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } catch (e) {
      throw UnknownException('Failed to get profile: $e');
    }
  }

  // Upload Avatar
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) throw AuthenticationException('Authentication token not found');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/auth/upload-avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return responseBody['fileUrl'] ?? '';
        } else {
          throw UnknownException(responseBody['message'] ?? 'Failed to upload avatar', statusCode: response.statusCode);
        }
      } else {
        throw UnknownException('Server returned an unexpected response format');
      }
    } on SocketException {
      throw NetworkException('Network error: Please check your internet connection');
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Avatar upload failed: $e');
    }
  }

  // Helper to parse successful responses
  Map<String, dynamic> _parseSuccessResponse(http.Response response) {
    if (response.headers['content-type']?.contains('application/json') ?? false) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody['data'] ?? responseBody;
      }
    }
    throw UnknownException('Unexpected response format');
  }
}