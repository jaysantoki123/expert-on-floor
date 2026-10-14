import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../exceptions/app_exceptions.dart';
import '../storage/secure_storage.dart';
import '../../utils/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _client = http.Client();
  }

  static String get _baseUrl => ApiConstants.baseUrl;
  static const _tokenRefreshEndpoint = '/auth/refresh-token';

  final _secureStorage = SecureStorage();
  late final http.Client _client;

  bool _isRefreshing = false;
  final _refreshCompleters = <Completer<String>>[];

  String get baseUrl => ApiConstants.baseUrl;

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _request('GET', path, headers: headers);
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _request('POST', path, headers: headers, body: body);
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _request('PUT', path, headers: headers, body: body);
  }

  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _request('PATCH', path, headers: headers, body: body);
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _request('DELETE', path, headers: headers);
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    
    // H27 Fix: Enforce SSL by rejecting plaintext HTTP unless on local dev emulators
    if (uri.scheme != 'https' && !uri.host.contains('localhost') && uri.host != '10.0.2.2') {
      throw NetworkException('Insecure HTTP connection is not allowed');
    }

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    var token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      if (_isTokenExpired(token)) {
        debugPrint('🔑 Token is expired. Refreshing proactively...');
        final refreshed = await _refreshToken();
        if (refreshed == null) {
          await _secureStorage.clearAuth();
          throw AuthenticationException('Session expired. Please log in again.', statusCode: 401);
        }
        token = refreshed;
      }
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: requestHeaders).timeout(const Duration(seconds: 15));
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: requestHeaders).timeout(const Duration(seconds: 15));
          break;
        default:
          throw UnknownException('Unsupported HTTP method: $method');
      }
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }

    if (response.statusCode == 401) {
      return _handle401(method, path, headers, body);
    }

    return _processResponse(response);
  }

  Future<http.Response> _handle401(
    String method,
    String path,
    Map<String, String>? headers,
    Object? body,
  ) async {
    final newToken = await _refreshToken();
    if (newToken == null) {
      await _secureStorage.clearAuth();
      throw AuthenticationException('Session expired. Please log in again.', statusCode: 401);
    }

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $newToken',
      ...?headers,
    };

    http.Response retryResponse;
    try {
      switch (method) {
        case 'GET':
          retryResponse = await _client.get(Uri.parse('$_baseUrl$path'), headers: requestHeaders).timeout(const Duration(seconds: 15));
          break;
        case 'POST':
          retryResponse = await _client.post(
            Uri.parse('$_baseUrl$path'),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          retryResponse = await _client.put(
            Uri.parse('$_baseUrl$path'),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case 'PATCH':
          retryResponse = await _client.patch(
            Uri.parse('$_baseUrl$path'),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case 'DELETE':
          retryResponse = await _client.delete(Uri.parse('$_baseUrl$path'), headers: requestHeaders).timeout(const Duration(seconds: 15));
          break;
        default:
          throw UnknownException('Unsupported HTTP method: $method');
      }
    } catch (e) {
      throw NetworkException('Retry request failed: $e');
    }

    return _processResponse(retryResponse);
  }

  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_tokenRefreshEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] ?? data['data']?['token'];
        final newRefreshToken = data['refreshToken'] ?? data['data']?['refreshToken'];

        if (newToken != null) {
          await _secureStorage.saveToken(newToken);
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }
          _notifyRefreshCompleters(newToken);
          return newToken;
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleters.clear();
    }
  }

  void _notifyRefreshCompleters(String token) {
    for (final completer in _refreshCompleters) {
      if (!completer.isCompleted) {
        completer.complete(token);
      }
    }
    _refreshCompleters.clear();
  }

  http.Response _processResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    String message = 'Request failed with status ${response.statusCode}';
    dynamic errorData;

    if (isJson) {
      try {
        errorData = jsonDecode(response.body);
        message = errorData['message'] ?? message;
      } catch (_) {}
    }

    switch (response.statusCode) {
      case 400:
        if (errorData is Map && errorData['errors'] != null) {
          throw ValidationException(
            message,
            errors: (errorData['errors'] as Map).map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            ),
            statusCode: 400,
          );
        }
        throw ValidationException(message, statusCode: 400);
      case 401:
        throw AuthenticationException(message, statusCode: 401);
      case 403:
        throw AuthorizationException(message, statusCode: 403);
      case 404:
        throw NotFoundException(message, statusCode: 404);
      case 500:
      case 502:
      case 503:
        throw ServerException(message, statusCode: response.statusCode);
      default:
        throw UnknownException(message, statusCode: response.statusCode);
    }
  }
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      
      var normalizedPayload = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalizedPayload));
      
      final Map<String, dynamic> claims = jsonDecode(decoded);
      final int? exp = claims['exp'];
      if (exp == null) return false;
      
      final expDateTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expDateTime.isBefore(DateTime.now().add(const Duration(seconds: 10)));
    } catch (_) {
      return true;
    }
  }
}