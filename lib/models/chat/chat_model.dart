class ChatModel {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String lastMessage;
  final String timestamp;
  final int? unreadCount;
  final bool isPinned;
  final bool isUnread;

  ChatModel({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount,
    this.isPinned = false,
    this.isUnread = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Extract last message content
    String lastMessageContent = '';
    if (json['last_message'] is Map<String, dynamic>) {
      lastMessageContent = json['last_message']?['content']?.toString() ?? '';
    } else {
      lastMessageContent = json['content']?.toString() ??
                          json['last_message']?.toString() ??
                          json['message']?.toString() ??
                          json['last_message_content']?.toString() ?? '';
    }

    // Extract name from other_user or fallback fields
    String userName = json['other_user']?['name']?.toString() ??
                      json['name']?.toString() ??
                      json['customer_name']?.toString() ??
                      json['user']?['name']?.toString() ??
                      json['potential_customer_name']?.toString() ??
                      json['business_owner_name']?.toString() ?? '';

    // Extract timestamp
    String timestamp = json['last_message_time']?.toString() ??
                      json['timestamp']?.toString() ??
                      json['updated_at']?.toString() ??
                      json['last_message_at']?.toString() ?? '';

    // Extract unread count
    int? unreadCount;
    if (json['unread_count'] != null) {
      if (json['unread_count'] is num) {
        unreadCount = (json['unread_count'] as num).toInt();
      } else {
        unreadCount = int.tryParse(json['unread_count']?.toString() ?? '0');
      }
    }

    return ChatModel(
      id: json['id']?.toString() ?? '',
      name: userName,
      profileImageUrl: json['other_user']?['profile_image']?.toString() ??
                      json['profile_image']?.toString() ??
                      json['profile_picture']?.toString() ??
                      json['avatar']?.toString(),
      lastMessage: lastMessageContent,
      timestamp: timestamp,
      unreadCount: unreadCount,
      isPinned: json['is_pinned'] == true,
      isUnread: json['is_unread'] == true || (unreadCount != null && unreadCount > 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImageUrl,
      'last_message': lastMessage,
      'timestamp': timestamp,
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'is_unread': isUnread,
    };
  }
}


class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}
