class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String? senderEmail;
  final String? senderName;
  final String? senderRole;
  final String content;
  final bool isRead;
  final String createdAt;
  final String? updatedAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderEmail,
    this.senderName,
    this.senderRole,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Handle both API and socket response formats
    String createdAtStr = json['created_at']?.toString() ?? '';
    if (createdAtStr.isEmpty) {
      createdAtStr = DateTime.now().toIso8601String();
    }
    
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      roomId: json['room']?.toString() ?? json['room_id']?.toString() ?? '',
      senderId: json['sender']?.toString() ?? json['sender_id']?.toString() ?? '',
      senderEmail: json['sender_email']?.toString(),
      senderName: json['sender_name']?.toString(),
      senderRole: json['sender_role']?.toString(),
      content: json['content']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 'true',
      createdAt: createdAtStr,
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_email': senderEmail,
      'sender_name': senderName,
      'sender_role': senderRole,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

