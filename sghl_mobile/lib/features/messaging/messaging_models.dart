class ConversationModel {
  final String id;
  final String subject;
  final bool isActive;
  final DateTime createdAt;
  final String? lastMessage;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.subject,
    required this.isActive,
    required this.createdAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool isMine(String currentUserId) => senderId == currentUserId;
}
