import '../common/constants/app_url.dart';
import '../common/utils/request_provider.dart';
import '../models/chat/chat_message.dart';
import '../models/chat/chat_room.dart';
import '../models/chat/chat_user.dart';

/// Chat API Service
/// Handles REST API calls for chat functionality
class ChatApiService {
  /// Get chat rooms with pagination
  Future<List<ChatRoom>> getChatRooms({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await RequestProvider.post(
        url: AppUrl.chatRooms,
        body: {}, // Empty body as per original API
      );

      if (response == null) return [];

      // Debug: Print response structure
      print('Chat rooms response type: ${response.runtimeType}');
      if (response is Map) {
        print('Chat rooms response keys: ${(response as Map).keys.toList()}');
      }

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        if (response['results'] != null) {
          // Paginated response
          final results = response['results'] as List<dynamic>;
          return results
              .map((r) {
                try {
                  return ChatRoom.fromJson(r as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing room: $e');
                  print('Room data: $r');
                  return null;
                }
              })
              .whereType<ChatRoom>()
              .toList();
        } else if (response['rooms'] != null) {
          // Rooms array
          final rooms = response['rooms'] as List<dynamic>;
          return rooms
              .map((r) {
                try {
                  return ChatRoom.fromJson(r as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing room: $e');
                  print('Room data: $r');
                  return null;
                }
              })
              .whereType<ChatRoom>()
              .toList();
        } else if (response['data'] != null && response['data'] is List) {
          // Data array
          final rooms = response['data'] as List<dynamic>;
          return rooms
              .map((r) {
                try {
                  return ChatRoom.fromJson(r as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing room: $e');
                  print('Room data: $r');
                  return null;
                }
              })
              .whereType<ChatRoom>()
              .toList();
        }
      } else if (response is List) {
        // Direct list
        return (response as List<dynamic>)
            .map((r) {
              try {
                return ChatRoom.fromJson(r as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing room: $e');
                print('Room data: $r');
                return null;
              }
            })
            .whereType<ChatRoom>()
            .toList();
      }

      return [];
    } catch (e, stackTrace) {
      print('Error fetching chat rooms: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get messages for a room with pagination
  Future<List<ChatMessage>> getRoomMessages({
    required String roomId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await RequestProvider.post(
        url: AppUrl.chatMessages,
        body: {
          'room_id': roomId,
        },
      );

      if (response == null) return [];

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        if (response['results'] != null) {
          // Paginated response
          final results = response['results'] as List<dynamic>;
          return results
              .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList();
        } else if (response['messages'] != null) {
          // Messages array
          final messages = response['messages'] as List<dynamic>;
          return messages
              .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList();
        } else if (response is List) {
          // Direct list
          return (response as List<dynamic>)
              .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        // Direct list
        return (response as List<dynamic>)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching room messages: $e');
      return [];
    }
  }

  /// Create a new chat room
  Future<ChatRoom?> createChatRoom(String otherUserId) async {
    try {
      final response = await RequestProvider.post(
        url: AppUrl.createChatRoom,
        body: {
          'other_user_id': otherUserId,
        },
      );

      if (response == null) return null;

      if (response is Map<String, dynamic>) {
        if (response['room'] != null) {
          return ChatRoom.fromJson(response['room'] as Map<String, dynamic>);
        } else {
          return ChatRoom.fromJson(response);
        }
      }

      return null;
    } catch (e) {
      print('Error creating chat room: $e');
      return null;
    }
  }

  /// Search users
  Future<List<ChatUser>> searchUsers({
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      final response = await RequestProvider.post(
        url: AppUrl.searchUsers,
        body: {
          'search': searchQuery,
          'limit': limit,
        },
      );

      if (response == null) return [];

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        if (response['results'] != null) {
          final results = response['results'] as List<dynamic>;
          return results
              .map((u) => ChatUser.fromJson(u as Map<String, dynamic>))
              .toList();
        } else if (response['users'] != null) {
          final users = response['users'] as List<dynamic>;
          return users
              .map((u) => ChatUser.fromJson(u as Map<String, dynamic>))
              .toList();
        } else if (response is List) {
          return (response as List<dynamic>)
              .map((u) => ChatUser.fromJson(u as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        return (response as List<dynamic>)
            .map((u) => ChatUser.fromJson(u as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead(String roomId) async {
    try {
      final response = await RequestProvider.post(
        url: AppUrl.markMessagesRead,
        body: {'room_id': roomId},
      );

      return response != null;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  /// Send a message
  Future<ChatMessage?> sendMessage(String roomId, String content) async {
    try {
      final response = await RequestProvider.post(
        url: AppUrl.sendMessage,
        body: {
          'room_id': roomId,
          'content': content,
        },
      );

      if (response == null) return null;

      if (response is Map<String, dynamic>) {
        return ChatMessage.fromJson(response);
      }

      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}

