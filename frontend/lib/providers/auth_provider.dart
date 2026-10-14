import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../core/exceptions/app_exceptions.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isTokenValidated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _isTokenValidated;
  bool get isExpert => _user?.role.isExpert ?? false;
  bool get isAdmin => _user?.role.isAdmin ?? false;
  bool get isLearner => _user?.role.isLearner ?? false;

  Future<void> init() async {
    _isLoading = true;
    _isTokenValidated = false;
    notifyListeners();

    try {
      _user = await _authService.getUserData();
      if (_user != null) {
        // Validate token with backend before granting access
        try {
          final updatedUser = await _authService.getMe();
          _user = updatedUser;
          _isTokenValidated = true;
          // Sync FCM token after successful validation
          await _syncFCMToken();
        } catch (e) {
          // Token invalid/expired and refresh failed — clear everything
          debugPrint('Token validation failed during init: $e');
          _user = null;
          _isTokenValidated = false;
          await _authService.logout();
        }
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
      _user = null;
      _isTokenValidated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isTokenValidated = true;
      await _syncFCMToken();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isTokenValidated = false;
    notifyListeners();
  }

  Future<bool> googleLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loggedInUser = await _authService.googleLogin();
      if (loggedInUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // Cancelled
      }
      _user = loggedInUser;
      _isTokenValidated = true;
      await _syncFCMToken();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.verifyOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String otp, String newPassword, String confirmPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email, otp, newPassword, confirmPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
        avatar: avatar,
      );
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Upload Avatar
  Future<String?> uploadAvatar(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fileUrl = await _authService.uploadAvatar(file);
      _isLoading = false;
      notifyListeners();
      return fileUrl;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper to retrieve and upload FCM token to backend
  Future<void> _syncFCMToken() async {
    try {
      final fcmService = FCMService();
      final token = await fcmService.getToken();
      if (token != null) {
        await fcmService.sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('❌ Error syncing FCM token in AuthProvider: $e');
    }
  }

  String _cleanError(dynamic e) {
    if (e is AppException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
