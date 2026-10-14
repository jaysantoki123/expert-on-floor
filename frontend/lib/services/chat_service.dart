import 'dart:convert';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../utils/api_constants.dart';

class ChatService {
  final _apiClient = ApiClient();
  final _secureStorage = SecureStorage();

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<List<dynamic>> getConversations() async {
    final relativeUrl = ApiConstants.conversationsUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? [];
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load conversations',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<dynamic>> getMessages(dynamic conversationId) async {
    final relativeUrl = ApiConstants.conversationMessagesUrl(conversationId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? [];
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load messages',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    dynamic conversationId,
    dynamic recipientId,
    required String text,
  }) async {
    final relativeUrl = ApiConstants.sendMessageUrl.replaceFirst(ApiConstants.baseUrl, '');
    final body = <String, dynamic>{
      'text': text,
    };
    if (conversationId != null) body['conversationId'] = conversationId;
    if (recipientId != null) body['recipientId'] = recipientId;

    final response = await _apiClient.post(
      relativeUrl,
      body: body,
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? {};
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to send message',
        statusCode: response.statusCode,
      );
    }
  }
}