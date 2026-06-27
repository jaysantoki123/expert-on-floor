import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';
import '../utils/api_constants.dart';
import '../logger_factory.dart';

class ChatService {
  IO.Socket? _socket;
  final _logger = AppLogger.create(topic: 'ChatService');

  // Stream Controllers for live socket events
  final _messageController = StreamController<MessageModel>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<MessageModel> get onMessageReceived => _messageController.stream;
  Stream<Map<String, dynamic>> get onTypingStatusChanged => _typingController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _readController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // Initialize Socket.io Connection
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      _logger.d('Socket already connected');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      _logger.w('Cannot connect socket: Token is null');
      return;
    }

    _logger.d('Connecting socket to ${ApiConstants.socketUrl}');

    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _logger.i('🔌 Socket connected successfully!');
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      _logger.w('🔌 Socket disconnected');
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      _logger.e('🔌 Socket connection error: $err');
      _connectionController.add(false);
    });

    // Listen to real-time incoming messages
    _socket!.on('receive_message', (data) {
      _logger.d('📩 Socket receive_message event: $data');
      try {
        final message = MessageModel.fromJson(data);
        _messageController.add(message);
      } catch (e) {
        _logger.e('Error parsing message from socket: $e');
      }
    });

    // Listen to typing status updates
    _socket!.on('typing', (data) {
      _logger.d('✍️ Socket typing event: $data');
      try {
        _typingController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _logger.e('Error parsing typing status: $e');
      }
    });

    // Listen to messages read confirmations
    _socket!.on('messages_read', (data) {
      _logger.d('👁️ Socket messages_read event: $data');
      try {
        _readController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _logger.e('Error parsing messages read event: $e');
      }
    });

    _socket!.connect();
  }

  // Disconnect Socket
  void disconnect() {
    if (_socket != null) {
      _logger.i('Disconnecting socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  // Socket Actions
  void joinConversation(int conversationId) {
    if (isConnected) {
      _socket!.emit('join_conversation', {'conversationId': conversationId});
      _logger.d('Emitted join_conversation: $conversationId');
    }
  }

  void leaveConversation(int conversationId) {
    if (isConnected) {
      _socket!.emit('leave_conversation', {'conversationId': conversationId});
      _logger.d('Emitted leave_conversation: $conversationId');
    }
  }

  void sendMessage(int? conversationId, int? recipientId, String text) {
    if (isConnected) {
      _socket!.emit('send_message', {
        'conversationId': conversationId,
        'recipientId': recipientId,
        'text': text,
      });
      _logger.d('Emitted send_message: convId=$conversationId, recipientId=$recipientId');
    } else {
      _logger.w('Socket is disconnected. Cannot send socket message. Using REST fallback.');
      sendRestMessage(conversationId, recipientId, text);
    }
  }

  void emitTyping(int conversationId, bool isTyping) {
    if (isConnected) {
      _socket!.emit('typing', {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });
    }
  }

  void markAsRead(int conversationId) {
    if (isConnected) {
      _socket!.emit('mark_as_read', {
        'conversationId': conversationId,
      });
      _logger.d('Emitted mark_as_read: conversationId=$conversationId');
    }
  }

  // REST API Methods
  Future<List<ConversationDetailModel>> fetchConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/conversations'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['success'] == true) {
          final List<dynamic> data = responseBody['data'] ?? [];
          return data.map((json) => ConversationDetailModel.fromJson(json)).toList();
        } else {
          throw HttpException(responseBody['message'] ?? 'Failed to load conversations');
        }
      } else {
        throw HttpException('Unexpected response format');
      }
    } catch (e) {
      _logger.e('Error fetching conversations: $e');
      rethrow;
    }
  }

  Future<List<MessageModel>> fetchMessages(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/conversations/$conversationId/messages?limit=50'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['success'] == true) {
          final List<dynamic> data = responseBody['data'] ?? [];
          return data.map((json) => MessageModel.fromJson(json)).toList();
        } else {
          throw HttpException(responseBody['message'] ?? 'Failed to load message history');
        }
      } else {
        throw HttpException('Unexpected response format');
      }
    } catch (e) {
      _logger.e('Error fetching messages: $e');
      rethrow;
    }
  }

  Future<MessageModel> sendRestMessage(int? conversationId, int? recipientId, String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        if (conversationId != null) 'conversationId': conversationId,
        if (recipientId != null) 'recipientId': recipientId,
        'text': text,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/messages'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (response.statusCode == 201 && responseBody['success'] == true) {
          return MessageModel.fromJson(responseBody['data']);
        } else {
          throw HttpException(responseBody['message'] ?? 'Failed to send message via REST');
        }
      } else {
        throw HttpException('Unexpected response format');
      }
    } catch (e) {
      _logger.e('Error sending REST message fallback: $e');
      rethrow;
    }
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
    _readController.close();
    _connectionController.close();
    disconnect();
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
