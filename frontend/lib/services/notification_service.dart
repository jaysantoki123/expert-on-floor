import 'dart:convert';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../utils/api_constants.dart';

class NotificationService {
  final _apiClient = ApiClient();

  Future<List<dynamic>> getNotifications() async {
    final relativeUrl = ApiConstants.notificationsUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? [];
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load notifications',
      );
    }
  }

  Future<void> markAllAsRead() async {
    final relativeUrl = ApiConstants.readAllNotificationsUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.patch(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] != true) {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to mark notifications as read',
      );
    }
  }
}