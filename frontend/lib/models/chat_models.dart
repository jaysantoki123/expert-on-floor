class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String text;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderObj = json['sender'];
    final sName = senderObj != null ? senderObj['name'] as String? : null;
    final sAvatar = senderObj != null ? senderObj['profileImage'] as String? : null;

    return MessageModel(
      id: json['id'] as int,
      conversationId: json['conversationId'] as int,
      senderId: json['senderId'] as int,
      text: json['text'] ?? '',
      type: json['type'] ?? 'text',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      senderName: sName,
      senderAvatar: sAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChatParticipantModel {
  final int id;
  final String name;
  final String? profileImage;
  final String role;

  ChatParticipantModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.role,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      role: json['role'] ?? 'learner',
    );
  }
}

class ConversationDetailModel {
  final int id;
  final ChatParticipantModel participant;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationDetailModel({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationDetailModel.fromJson(Map<String, dynamic> json) {
    final lastMsgObj = json['lastMessage'];
    final lastMsgText = lastMsgObj != null ? lastMsgObj['text'] as String? ?? '' : '';
    final lastMsgTimeStr = lastMsgObj != null ? lastMsgObj['timestamp'] as String? : null;

    return ConversationDetailModel(
      id: json['id'] as int,
      participant: ChatParticipantModel.fromJson(json['participant'] ?? {}),
      lastMessage: lastMsgText,
      lastMessageAt: lastMsgTimeStr != null ? DateTime.parse(lastMsgTimeStr) : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
