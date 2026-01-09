import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat/message_model.dart';
import '../models/chat/chat_message.dart';
import '../services/chat_api_service.dart';
import '../services/chat_socket_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  final ChatSocketService _socketService = ChatSocketService.instance;
  
  List<MessageModel> _messages = [];
  List<MessageModel> get messages => List.unmodifiable(_messages);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  String? _sendMessageError;
  String? get sendMessageError => _sendMessageError;
  
  String? _currentUserId;
  String? get currentUserId => _currentUserId;
  
  bool _isSocketConnected = false;
  bool get isSocketConnected => _isSocketConnected;
  
  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;
  
  bool _isOtherUserTyping = false;
  bool get isOtherUserTyping => _isOtherUserTyping;
  
  Timer? _typingDebounceTimer;
  Timer? _timestampUpdateTimer;
  
  String? _roomId;
  String? get roomId => _roomId;
  
  // Initialize provider
  Future<void> initialize(String roomId, String? currentUserId) async {
    _roomId = roomId;
    _currentUserId = currentUserId;
    _getCurrentUserId();
    await _initializeSocket();
    await _fetchMessages();
    _startTimestampUpdateTimer();
  }
  
  // Refresh messages
  Future<void> refreshMessages() async {
    await _fetchMessages();
  }
  
  void _getCurrentUserId() {
    // Current user ID should be passed from initialize method
    // This method is kept for consistency but user ID is set in initialize
  }
  
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }
  
  void _startTimestampUpdateTimer() {
    // Update timestamps every minute
    _timestampUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      notifyListeners();
    });
  }
  
  String formatMessageTime(DateTime dateTime) {
    // Ensure we're working with local time
    final localTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localTime.year, localTime.month, localTime.day);
    
    // Format time (e.g., "2:30 PM" or "10:15 AM")
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    if (messageDate == today) {
      // Today - show time only
      return '$displayHour:$minute $period';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday $displayHour:$minute $period';
    } else {
      // Older - show date and time
      return '${localTime.day}/${localTime.month}/${localTime.year} $displayHour:$minute $period';
    }
  }
  
  Future<void> _initializeSocket() async {
    // Check if already connected
    if (_socketService.isConnected) {
      _isSocketConnected = true;
      notifyListeners();
      _setupSocketListeners();
      _joinRoom();
      return;
    }
    
    // Connect if not connected (non-blocking)
    _isConnecting = true;
    notifyListeners();
    
    // Setup listeners before connecting
    _setupSocketListeners();
    
    // Connect to socket (non-blocking - don't wait too long)
    _socketService.connect().catchError((error) {
      debugPrint('Socket connection error: $error');
      _isConnecting = false;
      _isSocketConnected = false;
      notifyListeners();
    });
    
    // Wait a bit for connection, but don't block UI
    Future.delayed(const Duration(seconds: 5), () {
      if (_socketService.isConnected) {
        _isSocketConnected = true;
        _isConnecting = false;
        notifyListeners();
        _joinRoom();
      } else {
        _isConnecting = false;
        notifyListeners();
        debugPrint('Socket connection failed or timed out - will use API fallback');
      }
    });
  }
  
  void _setupSocketListeners() {
    // Listen for connection
    _socketService.onConnected = () {
      _isSocketConnected = true;
      _isConnecting = false;
      notifyListeners();
      _joinRoom();
    };
    
    // Listen for disconnection
    _socketService.onDisconnected = () {
      _isSocketConnected = false;
      notifyListeners();
    };
    
    // Listen for errors
    _socketService.onError = (error) {
      debugPrint('Socket error: $error');
      _errorMessage = error;
      notifyListeners();
    };
    
    // Listen for new messages
    _socketService.onMessageReceived = (data) {
      _handleNewMessage(data);
    };
    
    // Listen for message sent confirmation
    _socketService.onMessageSent = (data) {
      debugPrint('Message sent confirmation: $data');
    };
    
    // Listen for typing status changes
    _socketService.onTypingStatusChanged = (data) {
      final roomId = data['room_id']?.toString();
      final isTyping = data['is_typing'] == true || data['typing'] == true;
      
      // Only update if it's for this room
      if (roomId == _roomId) {
        _isOtherUserTyping = isTyping;
        notifyListeners();
        
        // Typing indicator updated
        notifyListeners();
      }
    };
  }
  
  void _joinRoom() {
    if (_socketService.isConnected && _roomId != null) {
      _socketService.joinRoom(_roomId!);
      debugPrint('Joined room: $_roomId');
    }
  }
  
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      // Convert socket message to ChatMessage first, then to MessageModel
      final chatMessage = ChatMessage.fromJson(data);
      final message = _convertChatMessageToMessageModel(chatMessage);
      
      // Only process if it's for this room
      if (message.roomId != _roomId) {
        return;
      }
      
      // Check if this is a message we sent (temp message)
      final tempIndex = _messages.indexWhere((m) => 
        m.id.startsWith('temp_') && 
        m.content == message.content &&
        m.isSentByMe == message.isSentByMe
      );
      
      if (tempIndex != -1) {
        // Replace temp message with real message
        _messages[tempIndex] = message;
      } else if (!_messages.any((m) => m.id == message.id)) {
        // Add new message if not already in list
        _messages.add(message);
      }
      
      // Sort messages by timestamp (oldest first, newest last) - like WhatsApp
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }
  
  Future<void> _fetchMessages() async {
    if (_roomId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final chatMessages = await _chatApiService.getRoomMessages(roomId: _roomId!);
      // Convert ChatMessage to MessageModel for UI compatibility
      final convertedMessages = chatMessages.map((msg) => _convertChatMessageToMessageModel(msg)).toList();
      
      // Sort messages by timestamp (oldest first, newest last) - like WhatsApp
      convertedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      _messages = convertedMessages;
      _isLoading = false;
      notifyListeners();
      
      // Mark messages as read after fetching
      _markMessagesAsRead();
    } catch (e) {
      _errorMessage = 'Failed to load messages';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  MessageModel _convertChatMessageToMessageModel(ChatMessage chatMessage) {
    // Parse UTC timestamp and convert to local time
    DateTime parseToLocal(String dateString) {
      final dateTime = DateTime.parse(dateString);
      // If the string ends with 'Z' or is in UTC format, convert to local
      if (dateString.endsWith('Z') || dateString.contains('+00:00')) {
        return dateTime.toLocal();
      }
      // If already in local time, return as is
      return dateTime.isUtc ? dateTime.toLocal() : dateTime;
    }
    
    return MessageModel(
      id: chatMessage.id,
      roomId: chatMessage.roomId,
      senderId: chatMessage.senderId,
      senderName: chatMessage.senderName ?? '',
      senderEmail: chatMessage.senderEmail,
      senderRole: chatMessage.senderRole,
      senderProfileImageUrl: null,
      content: chatMessage.content,
      createdAt: parseToLocal(chatMessage.createdAt),
      updatedAt: chatMessage.updatedAt != null ? parseToLocal(chatMessage.updatedAt!) : parseToLocal(chatMessage.createdAt),
      isRead: chatMessage.isRead,
      isSentByMe: _currentUserId != null && chatMessage.senderId == _currentUserId,
    );
  }
  
  Future<void> _markMessagesAsRead() async {
    if (_roomId == null) return;
    
    // Use socket if connected, otherwise use API
    if (_socketService.isConnected) {
      _socketService.markMessagesRead(_roomId!);
    } else {
      try {
        await _chatApiService.markMessagesAsRead(_roomId!);
      } catch (e) {
        // Silently fail - don't show error to user for mark read
        debugPrint('Failed to mark messages as read: $e');
      }
    }
  }
  
  Future<void> sendMessage(String content) async {
    if (_roomId == null) return;
    
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;
    
    // Stop typing when sending message
    _typingDebounceTimer?.cancel();
    if (_socketService.isConnected) {
      _socketService.stopTyping(_roomId!);
    }
    
    // Optimistically add message to UI
    final tempMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: _roomId!,
      senderId: _currentUserId ?? '',
      senderName: 'You',
      content: trimmedContent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isRead: false,
      isSentByMe: true,
    );
    
    _messages.add(tempMessage);
    // Sort messages by timestamp (oldest first, newest last) - like WhatsApp
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
    
    // Try to send via socket first, fallback to API if socket not connected
    if (_socketService.isConnected) {
      // Send message via socket
      _socketService.sendMessage(_roomId!, trimmedContent);
      // The message will be replaced when we receive the new_message event from server
    } else {
      // Fallback to API if socket not connected
      try {
        final sentChatMessage = await _chatApiService.sendMessage(_roomId!, trimmedContent);
        
        if (sentChatMessage != null) {
          final sentMessage = _convertChatMessageToMessageModel(sentChatMessage);
          
          // Replace temp message with server response
          final index = _messages.indexWhere((m) => m.id == tempMessage.id);
          if (index != -1) {
            _messages[index] = sentMessage;
          } else {
            _messages.add(sentMessage);
          }
          // Sort messages by timestamp (oldest first, newest last) - like WhatsApp
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          notifyListeners();
        }
      } catch (e) {
        // Remove temp message on error
        _messages.removeWhere((m) => m.id == tempMessage.id);
        _sendMessageError = 'Failed to send message. Please try again.';
        notifyListeners();
        debugPrint('Failed to send message: $e');
        
        // Clear error after showing
        Future.delayed(const Duration(milliseconds: 100), () {
          _sendMessageError = null;
          notifyListeners();
        });
      }
    }
  }
  
  void onTextChanged(String text) {
    // Cancel existing timer
    _typingDebounceTimer?.cancel();
    
    // Start typing if socket is connected
    if (_socketService.isConnected && text.trim().isNotEmpty && _roomId != null) {
      _socketService.startTyping(_roomId!);
    }
    
    // Set timer to stop typing after 2 seconds of inactivity
    _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
      if (_socketService.isConnected && _roomId != null) {
        _socketService.stopTyping(_roomId!);
      }
    });
  }
  
  void cleanup() {
    _typingDebounceTimer?.cancel();
    _timestampUpdateTimer?.cancel();
    // Stop typing when leaving
    if (_socketService.isConnected && _roomId != null) {
      _socketService.stopTyping(_roomId!);
    }
    // Leave room when cleaning up
    if (_socketService.isConnected && _roomId != null) {
      _socketService.leaveRoom(_roomId!);
    }
    // Clear socket listeners
    _socketService.onMessageReceived = null;
    _socketService.onMessageSent = null;
    _socketService.onConnected = null;
    _socketService.onDisconnected = null;
    _socketService.onError = null;
    _socketService.onTypingStatusChanged = null;
  }
  
  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}

