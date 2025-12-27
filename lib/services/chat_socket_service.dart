import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constants/app_constants.dart';

/// Chat Socket Service
/// Handles Socket.IO connection and real-time chat events
/// Singleton pattern to ensure all screens share the same socket connection
class ChatSocketService {
  static ChatSocketService? _instance;
  
  ChatSocketService._internal();
  
  static ChatSocketService get instance {
    _instance ??= ChatSocketService._internal();
    return _instance!;
  }

  IO.Socket? _socket;
  String? _authToken;
  final String _serverUrl = AppConstants.baseUrl;

  // Callbacks
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onTypingStatusChanged;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(Map<String, dynamic>)? onRoomReady;
  Function(Map<String, dynamic>)? onJoinedRoom;
  Function(Map<String, dynamic>)? onLeftRoom;
  Function(Map<String, dynamic>)? onMessageSent;
  Function(Map<String, dynamic>)? onMessagesMarkedRead;

  // Typing debounce timer
  Timer? _typingTimer;
  String? _currentTypingRoomId;
  
  // Connection completer to wait for connection
  Completer<void>? _connectionCompleter;

  /// Initialize and connect to socket
  Future<void> connect() async {
    // If already connected, return immediately
    if (_socket != null && _socket!.connected) {
      print('Socket already connected');
      return;
    }
    
    // If connection is in progress, wait for it
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      print('Connection already in progress, waiting...');
      return _connectionCompleter!.future;
    }
    
    // Create new completer for this connection attempt
    _connectionCompleter = Completer<void>();
    
    try {
      // Get token from storage
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('token');
      
      if (_authToken == null || _authToken!.isEmpty) {
        final error = 'Authentication token not found. Please login again.';
        onError?.call(error);
        _connectionCompleter!.completeError(error);
        _connectionCompleter = null;
        return;
      }
      
      // Verify token is valid by checking its format
      print('Token retrieved from storage, length: ${_authToken!.length}');
      
      // Test if we can reach the server with a simple HTTP request first
      // This helps verify network connectivity
      try {
        final testUrl = Uri.parse('$_serverUrl/chat/api/rooms/');
        print('Testing server connectivity to: $testUrl');
        // Just log - we'll let socket.io handle the actual connection
      } catch (e) {
        print('Error parsing server URL: $e');
      }

      // Disconnect existing connection if any
      if (_socket != null) {
        if (_socket!.connected) {
          _socket!.disconnect();
        }
        _socket!.dispose();
        _socket = null;
      }

       print('Creating new socket connection...');
       print('Server URL: $_serverUrl');
       print('Token length: ${_authToken?.length ?? 0}');
       print('Token preview: ${_authToken?.substring(0, _authToken!.length > 20 ? 20 : _authToken!.length)}...');
       print('Full token: $_authToken');
       
       // Try websocket-only transport (as suggested by troubleshooting guides)
       // This bypasses the polling handshake and goes straight to websocket
       _socket = IO.io(
         _serverUrl,
         IO.OptionBuilder()
             .setTransports(['websocket']) // Use ONLY websocket - bypass polling
             .enableAutoConnect() // Auto-connect
             .setExtraHeaders({
               'Authorization': 'Bearer $_authToken',
             })
             .setQuery({
               'token': _authToken,
             })
             .enableReconnection()
             .setReconnectionDelay(2000)
             .setReconnectionAttempts(10)
             .setTimeout(30000)
             .build(),
       );
       
       print('Socket created with websocket-only transport');
       
       print('Socket object created: ${_socket != null}');
       print('Socket autoConnect enabled, setting up listeners...');

       // Setup event listeners (autoConnect will connect automatically)
       _setupEventListeners();
       
       print('Listeners set up. Socket should auto-connect now...');
       
       // Give autoConnect a moment to start
       await Future.delayed(const Duration(milliseconds: 500));
       
       // Check if already connected (autoConnect might have connected quickly)
       if (_socket!.connected) {
         print('Socket already connected via autoConnect!');
         if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
           _connectionCompleter!.complete();
           _connectionCompleter = null;
         }
         return;
       }
       
       print('Waiting for autoConnect to establish connection...');
      
      // Add periodic status check for debugging
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_socket == null) {
          timer.cancel();
          return;
        }
        print('Socket status check - ID: ${_socket!.id}, Connected: ${_socket!.connected}, Disconnected: ${_socket!.disconnected}');
        if (_socket!.connected) {
          print('Socket connected! Cancelling status check timer.');
          timer.cancel();
        }
        // Cancel after 30 seconds
        if (timer.tick >= 30) {
          print('Status check timer expired after 30 seconds');
          timer.cancel();
        }
      });
      
      // Wait for connection with timeout
      try {
        await _connectionCompleter!.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('Socket connection timeout after 30 seconds');
            print('Final socket state - ID: ${_socket?.id}, Connected: ${_socket?.connected}');
            _connectionCompleter = null;
            throw TimeoutException('Socket connection timeout');
          },
        );
        print('Socket connection established successfully!');
      } catch (e) {
        _connectionCompleter = null;
        rethrow;
      }
    } catch (e) {
      print('Error connecting to Socket.IO: $e');
      final errorMsg = 'Failed to connect: $e';
      onError?.call(errorMsg);
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(e);
      }
      _connectionCompleter = null;
      rethrow;
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.on('connect', (_) {
      print('=== Socket.IO CONNECT EVENT FIRED ===');
      print('Socket ID: ${_socket!.id}');
      print('Socket connected status: ${_socket!.connected}');
      // Complete the connection completer if it exists
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        print('Completing connection completer successfully');
        _connectionCompleter!.complete();
        _connectionCompleter = null;
      }
      onConnected?.call();
    });
    
    // Connection error event
    _socket!.on('connect_error', (error) {
      print('=== Socket.IO connect_error EVENT FIRED ===');
      print('Error: $error');
      print('Error type: ${error.runtimeType}');
      if (error is Map) {
        print('Error details: $error');
      } else if (error is String) {
        print('Error string: $error');
      }
      print('Socket state - ID: ${_socket!.id}, Connected: ${_socket!.connected}');
      // Complete the connection completer with error if it exists
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        print('Completing connection completer with error');
        _connectionCompleter!.completeError(error);
        _connectionCompleter = null;
      }
      onError?.call('Connection error: $error');
    });
    
    // Listen for connection attempts
    _socket!.on('connecting', (data) {
      print('=== Socket.IO connecting EVENT FIRED ===');
      print('Connecting data: $data');
    });
    
    // Listen for connection attempts
    _socket!.on('reconnect_attempt', (attemptNumber) {
      print('=== Socket.IO reconnect_attempt EVENT FIRED ===');
      print('Reconnect attempt #$attemptNumber');
    });

    _socket!.on('disconnect', (reason) {
      print('Socket.IO disconnected. Reason: $reason');
      // Reset connection completer on disconnect
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError('Disconnected before connection established: $reason');
        _connectionCompleter = null;
      }
      onDisconnected?.call();
    });
    
    // Listen for reconnection attempts
    _socket!.on('reconnect', (attemptNumber) {
      print('Socket.IO reconnected after $attemptNumber attempts');
    });
    
    _socket!.on('reconnect_attempt', (attemptNumber) {
      print('Socket.IO reconnect attempt #$attemptNumber');
    });
    
    _socket!.on('reconnect_error', (error) {
      print('Socket.IO reconnect error: $error');
    });
    
    _socket!.on('reconnect_failed', (error) {
      print('Socket.IO reconnect failed: $error');
    });

    _socket!.on('error', (data) {
      print('Socket.IO error: $data');
      String errorMessage = 'Unknown error occurred';
      if (data is Map && data['message'] != null) {
        errorMessage = data['message'] as String;
      } else if (data is String) {
        errorMessage = data;
      }
      // Complete connection completer with error if connection was in progress
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(errorMessage);
        _connectionCompleter = null;
      }
      onError?.call(errorMessage);
    });

    // Chat events
    _socket!.on('room_ready', (data) {
      print('Room ready: $data');
      if (data is Map<String, dynamic>) {
        onRoomReady?.call(data);
      }
    });

    _socket!.on('joined_room', (data) {
      print('Joined room: $data');
      if (data is Map<String, dynamic>) {
        onJoinedRoom?.call(data);
      }
    });

    _socket!.on('left_room', (data) {
      print('Left room: $data');
      if (data is Map<String, dynamic>) {
        onLeftRoom?.call(data);
      }
    });

    _socket!.on('new_message', (data) {
      print('New message: $data');
      if (data is Map<String, dynamic>) {
        onMessageReceived?.call(data);
      }
    });

    _socket!.on('message_sent', (data) {
      print('Message sent: $data');
      if (data is Map<String, dynamic>) {
        onMessageSent?.call(data);
      }
    });

    _socket!.on('user_typing', (data) {
      print('User typing: $data');
      if (data is Map<String, dynamic>) {
        onTypingStatusChanged?.call(data);
      }
    });

    _socket!.on('messages_marked_read', (data) {
      print('Messages marked read: $data');
      if (data is Map<String, dynamic>) {
        onMessagesMarkedRead?.call(data);
      }
    });
  }

  /// Get or create a chat room
  void getOrCreateRoom(String otherUserId) {
    _socket?.emit('get_or_create_room', {
      'other_user_id': otherUserId,
    });
  }

  /// Join a room
  void joinRoom(String roomId) {
    _socket?.emit('join_room', {
      'room_id': roomId,
    });
  }

  /// Leave a room
  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {
      'room_id': roomId,
    });
  }

  /// Send a message
  void sendMessage(String roomId, String content) {
    if (content.trim().isEmpty) return;
    
    if (_socket == null || !_socket!.connected) {
      print('Socket not connected, cannot send message');
      onError?.call('Socket not connected. Please try again.');
      return;
    }
    
    print('Sending message to room $roomId: ${content.trim()}');
    _socket!.emit('send_message', {
      'room_id': roomId,
      'content': content.trim(),
    });
  }

  /// Start typing indicator (with debounce)
  void startTyping(String roomId) {
    _currentTypingRoomId = roomId;
    
    // Cancel existing timer
    _typingTimer?.cancel();
    
    // Emit typing start
    _socket?.emit('typing_start', {
      'room_id': roomId,
    });

    // Set timer to stop typing after 3 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (_currentTypingRoomId == roomId) {
        stopTyping(roomId);
      }
    });
  }

  /// Stop typing indicator
  void stopTyping(String roomId) {
    _typingTimer?.cancel();
    _currentTypingRoomId = null;
    
    _socket?.emit('typing_stop', {
      'room_id': roomId,
    });
  }

  /// Mark messages as read
  void markMessagesRead(String roomId) {
    _socket?.emit('mark_messages_read', {
      'room_id': roomId,
    });
  }

  /// Disconnect from socket
  void disconnect() {
    _typingTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Check if connected
  bool get isConnected => _socket?.connected ?? false;

  /// Reconnect if disconnected
  Future<void> reconnectIfNeeded() async {
    if (!isConnected) {
      await connect();
    }
  }
}

