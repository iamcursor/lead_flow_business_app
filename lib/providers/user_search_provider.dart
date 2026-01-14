import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat/chat_user.dart';
import '../models/chat/chat_room.dart';
import '../services/chat_api_service.dart';

/// User Search Provider
/// Handles user search and chat room creation functionality
/// Separate from ChatProvider to keep concerns isolated
class UserSearchProvider with ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  
  // Search State
  List<ChatUser> _searchedUsers = [];
  List<ChatUser> get searchedUsers => List.unmodifiable(_searchedUsers);
  
  bool _isSearchingUsers = false;
  bool get isSearchingUsers => _isSearchingUsers;
  
  String? _searchError;
  String? get searchError => _searchError;
  
  // Room Creation State
  bool _isCreatingRoom = false;
  bool get isCreatingRoom => _isCreatingRoom;
  
  String? _createRoomError;
  String? get createRoomError => _createRoomError;
  
  Timer? _searchDebounceTimer;
  
  /// Search users with debounce
  void searchUsers(String query) {
    // Cancel existing debounce timer
    _searchDebounceTimer?.cancel();
    
    // Clear previous error
    _searchError = null;
    
    // If query is empty, clear search results immediately
    if (query.trim().isEmpty) {
      _searchedUsers = [];
      _isSearchingUsers = false;
      notifyListeners();
      return;
    }
    
    // Debounce search API call
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performUserSearch(query.trim());
    });
    
    notifyListeners();
  }
  
  /// Fetch all users (empty search)
  Future<void> fetchAllUsers() async {
    await _performUserSearch('');
  }
  
  /// Perform the actual user search
  Future<void> _performUserSearch(String query) async {
    _isSearchingUsers = true;
    _searchError = null;
    notifyListeners();
    
    try {
      // Search with query (empty string will return all users)
      final users = await _chatApiService.searchUsers(searchQuery: query);
      _searchedUsers = users;
      _isSearchingUsers = false;
      _searchError = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching users: $e');
      _searchedUsers = [];
      _isSearchingUsers = false;
      _searchError = 'Failed to search users. Please try again.';
      notifyListeners();
    }
  }
  
  /// Create a chat room with the selected user
  Future<ChatRoom?> createChatRoomWithUser(String userId) async {
    _isCreatingRoom = true;
    _createRoomError = null;
    notifyListeners();
    
    try {
      final room = await _chatApiService.createChatRoom(userId);
      _isCreatingRoom = false;
      
      if (room == null) {
        _createRoomError = 'Failed to create chat room. Please try again.';
        notifyListeners();
        return null;
      }
      
      _createRoomError = null;
      notifyListeners();
      return room;
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      _isCreatingRoom = false;
      _createRoomError = 'Failed to create chat room. Please try again.';
      notifyListeners();
      return null;
    }
  }
  
  /// Clear search results
  void clearSearch() {
    _searchedUsers = [];
    _isSearchingUsers = false;
    _searchError = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

