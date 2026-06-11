import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expert_model.dart';
import '../utils/api_constants.dart';
import '../logger_factory.dart';

class ExpertService {
  Future<List<ExpertModel>> getExperts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final logger = AppLogger.create(topic: 'ExpertService');
      logger.d("Retrieved Token from Storage: $token");

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      logger.d("HEADERS: {Content-Type: application/json, Authorization: Bearer $token}");

      final response = await http
          .get(Uri.parse(ApiConstants.expertsUrl), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['success'] == true) {
          final List<dynamic> data = responseBody['data'] ?? [];
          return data.map((json) => ExpertModel.fromJson(json)).toList();
        } else if (response.statusCode == 401) {
          throw HttpException('Unauthorized: Please login again');
        } else {
          throw HttpException(
            responseBody['message'] ?? 'Failed to load experts',
          );
        }
      } else {
        throw HttpException('Server returned an unexpected response format');
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
