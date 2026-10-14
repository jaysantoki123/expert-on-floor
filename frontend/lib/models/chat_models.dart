import 'package:flutter/material.dart';

class ConversationModel {
  final String id;
  final String? participantId;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;
  final Color avatarColor;
  final String? avatarText;
  final bool isSupportChat;
  final String role;
  final String? profileImage;

  const ConversationModel({
    required this.id,
    this.participantId,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    required this.avatarColor,
    this.avatarText,
    this.isSupportChat = false,
    required this.role,
    this.profileImage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final participant = json['participant'] ?? {};
    final participantId = participant['id']?.toString();
    final id = json['id']?.toString() ?? '';
    final name = participant['name'] ?? 'User';
    final profileImage = participant['profileImage'];
    final role = participant['role'] ?? 'Member';

    final lastMessageObj = json['lastMessage'] ?? {};
    final lastMessage = lastMessageObj['text'] ?? '';
    final timestamp = lastMessageObj['timestamp'] ?? '';

    String time = 'Just now';
    if (timestamp.isNotEmpty) {
      try {
        final parsed = DateTime.parse(timestamp).toLocal();
        final now = DateTime.now();
        if (parsed.year == now.year && parsed.month == now.month && parsed.day == now.day) {
          final h = parsed.hour > 12 ? parsed.hour - 12 : parsed.hour;
          final m = parsed.minute.toString().padLeft(2, '0');
          final period = parsed.hour >= 12 ? 'PM' : 'AM';
          time = '$h:$m $period';
        } else {
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          time = '${parsed.day} ${months[parsed.month - 1]}';
        }
      } catch (_) {}
    }

    final avatarColor = Color((name.hashCode & 0x00FFFFFF) | 0xFF000000);
    final avatarText = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return ConversationModel(
      id: id,
      participantId: participantId,
      name: name,
      lastMessage: lastMessage,
      time: time,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: false,
      isTyping: false,
      avatarColor: avatarColor,
      avatarText: avatarText,
      role: role,
      profileImage: profileImage,
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isSent;
  final String time;
  final String status;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isSent,
    required this.time,
    required this.status,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['senderId']?.toString() ?? '';
    final isSent = senderId == currentUserId;
    
    final createdAtStr = json['createdAt'] ?? '';
    DateTime createdAt = DateTime.now();
    String time = 'Just now';
    if (createdAtStr.isNotEmpty) {
      try {
        createdAt = DateTime.parse(createdAtStr).toLocal();
        final h = createdAt.hour > 12 ? createdAt.hour - 12 : (createdAt.hour == 0 ? 12 : createdAt.hour);
        final m = createdAt.minute.toString().padLeft(2, '0');
        final period = createdAt.hour >= 12 ? 'PM' : 'AM';
        time = '$h:$m $period';
      } catch (_) {}
    }

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      isSent: isSent,
      time: time,
      status: 'read',
      createdAt: createdAt,
    );
  }
}
