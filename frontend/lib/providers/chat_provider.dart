import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../utils/api_constants.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  IO.Socket? _socket;

  List<ConversationModel> _conversations = [];
  List<ChatMessage> _messages = [];
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  String? _error;
  String? _currentUserId;
  String? _activeConversationId;

  // ── WebRTC Call State and Callbacks ───────────
  Map<String, dynamic>? _incomingCallData;
  Map<String, dynamic>? get incomingCallData => _incomingCallData;
  String? get currentUserId => _currentUserId;

  Function(Map<String, dynamic>)? onCallAnsweredCallback;
  Function(Map<String, dynamic>)? onIceCandidateReceivedCallback;
  Function(Map<String, dynamic>)? onCallRejectedCallback;
  Function(Map<String, dynamic>)? onCallHungupCallback;

  List<ConversationModel> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get error => _error;
  bool get isConnected => _socket != null && _socket!.connected;
  IO.Socket? get socket => _socket;

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  void clearIncomingCall() {
    _incomingCallData = null;
    notifyListeners();
  }

  // Connect socket with current user token
  void connectSocket(String token) {
    if (_socket != null) {
      if (_socket!.connected) return;
      _socket!.disconnect();
      _socket = null;
    }

    debugPrint('🔌 Initializing socket client at ${ApiConstants.socketUrl}');

    _socket = IO.io(ApiConstants.socketUrl, IO.OptionBuilder()
      .setTransports(['websocket']) // essential for flutter/mobile connection
      .setAuth({'token': token})
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      debugPrint('🔌 Socket connected successfully to backend');
      // Re-join active conversation if any
      if (_activeConversationId != null) {
        _socket!.emit('join_conversation', _activeConversationId);
      }
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 Socket disconnected');
      notifyListeners();
    });

    _socket!.onConnectError((err) {
      debugPrint('🔌 Socket connection error: $err');
    });

    // Listen for incoming messages globally to update conversation list
    _socket!.on('message_received', _handleGlobalMessage);

    // ── WebRTC Signaling Events ───────────────────
    _socket!.on('call_received', _handleCallReceived);
    _socket!.on('call_answered', _handleCallAnswered);
    _socket!.on('ice_candidate_received', _handleIceCandidate);
    _socket!.on('call_rejected', _handleCallRejected);
    _socket!.on('call_hungup', _handleCallHungup);
  }

  void _handleGlobalMessage(dynamic data) {
    debugPrint('💬 Received global message through socket.');
    _handleIncomingGlobalMessage(data);
  }

  void _handleCallReceived(dynamic data) {
    debugPrint('📞 Received incoming call event: $data');
    _incomingCallData = data != null ? Map<String, dynamic>.from(data) : null;
    notifyListeners();
  }

  void _handleCallAnswered(dynamic data) {
    debugPrint('📞 Received call answered event: $data');
    if (onCallAnsweredCallback != null && data != null) {
      onCallAnsweredCallback!(Map<String, dynamic>.from(data));
    }
  }

  void _handleIceCandidate(dynamic data) {
    if (onIceCandidateReceivedCallback != null && data != null) {
      onIceCandidateReceivedCallback!(Map<String, dynamic>.from(data));
    }
  }

  void _handleCallRejected(dynamic data) {
    debugPrint('📞 Received call rejected event');
    _incomingCallData = null;
    notifyListeners();
    if (onCallRejectedCallback != null && data != null) {
      onCallRejectedCallback!(Map<String, dynamic>.from(data));
    }
  }

  void _handleCallHungup(dynamic data) {
    debugPrint('📞 Received call hungup event');
    _incomingCallData = null;
    notifyListeners();
    if (onCallHungupCallback != null && data != null) {
      onCallHungupCallback!(Map<String, dynamic>.from(data));
    }
  }

  void disconnectSocket() {
    if (_socket != null) {
      // Clean up all event listeners
      _socket!.off('message_received');
      _socket!.off('call_received');
      _socket!.off('call_answered');
      _socket!.off('ice_candidate_received');
      _socket!.off('call_rejected');
      _socket!.off('call_hungup');
      _socket!.off('new_message');
      
      _socket!.disconnect();
      _socket = null;
    }
    _activeConversationId = null;
    // Clear WebRTC callbacks to prevent memory leaks
    onCallAnsweredCallback = null;
    onIceCandidateReceivedCallback = null;
    onCallRejectedCallback = null;
    onCallHungupCallback = null;
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }

  // Fetch all conversations from backend
  Future<void> fetchConversations() async {
    _isLoadingConversations = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _chatService.getConversations();
      _conversations = data
          .map((json) => ConversationModel.fromJson(json, _currentUserId ?? ''))
          .toList();
      _isLoadingConversations = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  // Fetch messages inside a specific conversation
  Future<void> fetchMessages(dynamic conversationId) async {
    _isLoadingMessages = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _chatService.getMessages(conversationId);
      final List<ChatMessage> loaded = data
          .map((json) => ChatMessage.fromJson(json, _currentUserId ?? ''))
          .toList();
      // Server returns newest first, so we reverse it to display oldest first
      _messages = loaded.reversed.toList();
      _isLoadingMessages = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Enter a conversation room
  void joinConversation(dynamic conversationId) {
    if (_socket == null) return;
    final convId = conversationId.toString();
    
    // Leave previous conversation if different
    if (_activeConversationId != null && _activeConversationId != convId) {
      leaveConversation(_activeConversationId!);
    }
    
    _activeConversationId = convId;
    debugPrint('💬 Joining socket conversation: $convId');
    _socket!.emit('join_conversation', convId);

    // Set up active message handler (remove existing first)
    _socket!.off('new_message');
    _socket!.on('new_message', _handleActiveConversationMessage);
  }

  void _handleActiveConversationMessage(dynamic data) {
    debugPrint('💬 Received active conversation new_message.');
    final ChatMessage msg = ChatMessage.fromJson(data, _currentUserId ?? '');
    
    // Avoid duplicates
    if (!_messages.any((m) => m.id == msg.id)) {
      _messages.add(msg);
      _updateConversationLastMessage(msg, convId: _activeConversationId);
      notifyListeners();
    }
  }

  // Leave a conversation room
  void leaveConversation(dynamic conversationId) {
    if (_socket == null) return;
    final convId = conversationId.toString();
    debugPrint('💬 Leaving socket conversation: $convId');
    _socket!.emit('leave_conversation', convId);
    _socket!.off('new_message');
    
    if (_activeConversationId == convId) {
      _activeConversationId = null;
    }
  }

  // Send a message
  Future<void> sendMessage({
    dynamic conversationId,
    dynamic recipientId,
    required String text,
  }) async {
    // If socket is connected, emit send_message
    if (_socket != null && _socket!.connected) {
      debugPrint('💬 Sending message via socket emit.');
      _socket!.emit('send_message', {
        'conversationId': conversationId,
        'recipientId': recipientId,
        'text': text,
      });
    } else {
      debugPrint('💬 Socket disconnected, sending message via REST fallback');
      try {
        final data = await _chatService.sendMessage(
          conversationId: conversationId,
          recipientId: recipientId,
          text: text,
        );
        // Manual insertion if REST succeeded
        final ChatMessage msg = ChatMessage.fromJson(data, _currentUserId ?? '');
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
          _updateConversationLastMessage(msg, convId: conversationId?.toString());
          notifyListeners();
        }
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  // Helpers
  void _handleIncomingGlobalMessage(dynamic data) {
    final conversationId = data['conversationId']?.toString();
    final msgJson = data['message'];
    if (msgJson != null && conversationId != null) {
      final ChatMessage msg = ChatMessage.fromJson(msgJson, _currentUserId ?? '');
      _updateConversationLastMessage(msg, convId: conversationId);
      
      // If we are actively looking at this conversation, let joinConversation's 
      // new_message handler append it. But if joinConversation wasn't connected, 
      // we append here.
      if (_activeConversationId != conversationId) {
        notifyListeners();
      }
    }
  }

  void _updateConversationLastMessage(ChatMessage msg, {String? convId}) {
    final String? targetId = convId;
    if (targetId == null) return;
    
    // Find conversation and update last message
    final idx = _conversations.indexWhere((c) => c.id == targetId);
    if (idx != -1) {
      final old = _conversations[idx];
      _conversations[idx] = ConversationModel(
        id: old.id,
        name: old.name,
        lastMessage: msg.text,
        time: msg.time,
        unreadCount: old.unreadCount + (msg.isSent ? 0 : 1),
        isOnline: old.isOnline,
        isTyping: old.isTyping,
        avatarColor: old.avatarColor,
        avatarText: old.avatarText,
        isSupportChat: old.isSupportChat,
        role: old.role,
        profileImage: old.profileImage,
      );
    } else {
      // Re-fetch conversation list to get new conversations
      fetchConversations();
    }
  }

  // ── WebRTC Signaling Emit Helpers ──────────────

  void emitCallUser({
    required String recipientId,
    required String conversationId,
    required String callerName,
    required Map<String, dynamic> offer,
  }) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('📞 Socket is disconnected, cannot emit call_user');
      return;
    }
    debugPrint('📞 Emitting call_user to $recipientId');
    _socket!.emit('call_user', {
      'recipientId': recipientId,
      'conversationId': conversationId,
      'callerName': callerName,
      'offer': offer,
    });
  }

  void emitAnswerCall({
    required String callerId,
    required Map<String, dynamic> answer,
  }) {
    if (_socket == null || !_socket!.connected) return;
    debugPrint('📞 Emitting answer_call to $callerId');
    _socket!.emit('answer_call', {
      'callerId': callerId,
      'answer': answer,
    });
  }

  void emitIceCandidate({
    required String targetId,
    required Map<String, dynamic> candidate,
  }) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('ice_candidate', {
      'targetId': targetId,
      'candidate': candidate,
    });
  }

  void emitRejectCall({required String callerId}) {
    if (_socket == null || !_socket!.connected) return;
    debugPrint('📞 Emitting reject_call to $callerId');
    _socket!.emit('reject_call', {
      'callerId': callerId,
    });
    _incomingCallData = null;
    notifyListeners();
  }

  void emitHangup({required String targetId}) {
    if (_socket == null || !_socket!.connected) return;
    debugPrint('📞 Emitting hangup to $targetId');
    _socket!.emit('hangup', {
      'targetId': targetId,
    });
    _incomingCallData = null;
    notifyListeners();
  }
}