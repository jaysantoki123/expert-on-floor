import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ConversationDetailModel> _conversations = [];
  List<MessageModel> _messages = [];
  ConversationDetailModel? _activeConversation;
  int? _currentUserId;
  bool _isLoading = false;
  String? _error;
  
  final Map<int, String?> _typingStatuses = {};

  List<ConversationDetailModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  ConversationDetailModel? get activeConversation => _activeConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? getTypingStatus(int conversationId) => _typingStatuses[conversationId];

  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _readSub;

  Future<void> init(int currentUserId) async {
    _currentUserId = currentUserId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _chatService.connect();
      _setupListeners();
      await loadConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupListeners() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _readSub?.cancel();

    _msgSub = _chatService.onMessageReceived.listen((message) {
      _handleIncomingMessage(message);
    });

    _typingSub = _chatService.onTypingStatusChanged.listen((data) {
      final int? conversationId = data['conversationId'] != null 
          ? int.tryParse(data['conversationId'].toString()) 
          : null;
      final int? senderId = data['userId'] != null 
          ? int.tryParse(data['userId'].toString()) 
          : null;
      final bool isTyping = data['isTyping'] ?? false;

      if (conversationId != null && senderId != _currentUserId) {
        if (isTyping) {
          _typingStatuses[conversationId] = 'Typing...';
        } else {
          _typingStatuses.remove(conversationId);
        }
        notifyListeners();
      }
    });

    _readSub = _chatService.onMessagesRead.listen((data) {
      final int? conversationId = data['conversationId'] != null 
          ? int.tryParse(data['conversationId'].toString()) 
          : null;
      if (conversationId != null && _activeConversation?.id == conversationId) {
        _messages = _messages.map((msg) {
          if (msg.senderId == _currentUserId) {
            return MessageModel(
              id: msg.id,
              conversationId: msg.conversationId,
              senderId: msg.senderId,
              text: msg.text,
              type: msg.type,
              isRead: true,
              createdAt: msg.createdAt,
              senderName: msg.senderName,
              senderAvatar: msg.senderAvatar,
            );
          }
          return msg;
        }).toList();
        notifyListeners();
      }
    });
  }

  void _handleIncomingMessage(MessageModel message) {
    if (_activeConversation?.id == message.conversationId) {
      if (!_messages.any((m) => m.id == message.id)) {
        _messages.add(message);
        if (message.senderId != _currentUserId) {
          _chatService.markAsRead(message.conversationId);
        }
      }
    }

    final convIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (convIndex != -1) {
      final existingConv = _conversations[convIndex];
      final isNewUnread = message.senderId != _currentUserId && _activeConversation?.id != message.conversationId;
      final newUnreadCount = isNewUnread ? existingConv.unreadCount + 1 : existingConv.unreadCount;

      _conversations[convIndex] = ConversationDetailModel(
        id: existingConv.id,
        participant: existingConv.participant,
        lastMessage: message.text,
        lastMessageAt: message.createdAt,
        unreadCount: newUnreadCount,
      );
    } else {
      loadConversations();
    }

    _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    notifyListeners();
  }

  Future<void> loadConversations() async {
    try {
      final list = await _chatService.fetchConversations();
      _conversations = list;
      _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectConversation(ConversationDetailModel conversation) async {
    if (_activeConversation != null) {
      _chatService.leaveConversation(_activeConversation!.id);
    }

    _activeConversation = conversation;
    _messages = [];
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _chatService.fetchMessages(conversation.id);
      _messages = history.reversed.toList();
      _chatService.joinConversation(conversation.id);
      _chatService.markAsRead(conversation.id);

      final convIndex = _conversations.indexWhere((c) => c.id == conversation.id);
      if (convIndex != -1) {
        _conversations[convIndex] = ConversationDetailModel(
          id: conversation.id,
          participant: conversation.participant,
          lastMessage: conversation.lastMessage,
          lastMessageAt: conversation.lastMessageAt,
          unreadCount: 0,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (_activeConversation == null || _currentUserId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = MessageModel(
      id: tempId,
      conversationId: _activeConversation!.id,
      senderId: _currentUserId!,
      text: text,
      type: 'text',
      isRead: false,
      createdAt: DateTime.now(),
    );
    _messages.add(tempMsg);
    notifyListeners();

    try {
      _chatService.sendMessage(_activeConversation!.id, null, text);

      final convIndex = _conversations.indexWhere((c) => c.id == _activeConversation!.id);
      if (convIndex != -1) {
        final existingConv = _conversations[convIndex];
        _conversations[convIndex] = ConversationDetailModel(
          id: existingConv.id,
          participant: existingConv.participant,
          lastMessage: text,
          lastMessageAt: DateTime.now(),
          unreadCount: existingConv.unreadCount,
        );
        _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      }
    } catch (e) {
      _error = e.toString();
      _messages.removeWhere((m) => m.id == tempId);
      notifyListeners();
    }
  }

  Future<void> startNewConversation(int recipientId, String text) async {
    _isLoading = true;
    notifyListeners();

    try {
      final msg = await _chatService.sendRestMessage(null, recipientId, text);
      await loadConversations();
      final newConv = _conversations.firstWhere((c) => c.id == msg.conversationId);
      await selectConversation(newConv);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTyping(bool isTyping) {
    if (_activeConversation != null) {
      _chatService.emitTyping(_activeConversation!.id, isTyping);
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _readSub?.cancel();
    _chatService.dispose();
    super.dispose();
  }
}
