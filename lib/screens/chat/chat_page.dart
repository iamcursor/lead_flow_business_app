import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/chat/chat_model.dart';
import '../../models/chat/chat_user.dart';
import 'chat_detail_page.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_search_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.fetchChatRooms();
      provider.startChatRoomsTimestampUpdateTimer();
    });
    _searchController.addListener(() {
      final searchProvider = Provider.of<UserSearchProvider>(context, listen: false);
      searchProvider.searchUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Filter Buttons
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return _buildFilterButtons(provider);
              },
            ),

            // Chat List or Search Results
            Expanded(
              child: Consumer2<ChatProvider, UserSearchProvider>(
                builder: (context, chatProvider, searchProvider, child) {
                  // Show search results if there are any searched users or if search is active
                  if (searchProvider.searchedUsers.isNotEmpty || searchProvider.isSearchingUsers) {
                    return _buildSearchResults(searchProvider);
                  }
                  return _buildChatList(chatProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Center(
              child: Text(
                'Chats',
                style: AppTextStyles.appBarTitle.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),

          // Filter Icon
          
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingS,
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onTap: () {
                  // Fetch all users when search bar is clicked
                  final searchProvider = Provider.of<UserSearchProvider>(context, listen: false);
                  searchProvider.fetchAllUsers();
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.inputHint.copyWith(
                    fontSize: 16.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: AppDimensions.iconM,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                style: AppTextStyles.inputText.copyWith(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

          SizedBox(width: AppDimensions.paddingS),

          // Filter Button
          Container(
            width: 44.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: Theme.of(context).colorScheme.onSurface,
                size: AppDimensions.iconM,
              ),
              onPressed: () {
                // TODO: Show filter/sort options
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(ChatProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingS,
      ),
      child: Row(
        children: [
          _buildFilterButton(
            label: 'All',
            isSelected: provider.selectedFilter == 'All',
            onTap: () => provider.setSelectedFilter('All'),
          ),
          SizedBox(width: AppDimensions.paddingS),
          _buildFilterButton(
            label: 'Unread',
            isSelected: provider.selectedFilter == 'Unread',
            onTap: () => provider.setSelectedFilter('Unread'),
          ),
          SizedBox(width: AppDimensions.paddingS),
          _buildFilterButton(
            label: 'Pinned',
            isSelected: provider.selectedFilter == 'Pinned',
            onTap: () => provider.setSelectedFilter('Pinned'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData icon;
    switch (label) {
      case 'All':
        icon = Icons.email;
        break;
      case 'Unread':
        icon = Icons.mark_email_unread;
        break;
      case 'Pinned':
        icon = Icons.push_pin;
        break;
      default:
        icon = Icons.circle;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.w,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary 
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: AppDimensions.paddingXS),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(ChatProvider provider) {
    if (provider.isLoadingChatRooms && provider.allChats.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (provider.chatRoomsErrorMessage != null && provider.allChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.chatRoomsErrorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppDimensions.paddingM),
            ElevatedButton(
              onPressed: () => provider.fetchChatRooms(),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredChats = provider.filteredChats;

    if (filteredChats.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No chats found'
              : 'No chats yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchChatRooms(),
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingHorizontal,
          vertical: AppDimensions.paddingS,
        ),
        itemCount: filteredChats.length + 1, // +1 for "Recent" label
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Recent" label
            return Padding(
              padding: EdgeInsets.only(
                bottom: AppDimensions.paddingM,
                top: AppDimensions.paddingS,
              ),
              child: Text(
                'Recent',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            );
          }

          final chat = filteredChats[index - 1];
          return _buildChatItem(chat, provider);
        },
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat, ChatProvider provider) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              roomId: chat.id,
              contactName: chat.name,
              contactProfileImageUrl: chat.profileImageUrl,
            ),
          ),
        );
        // Refresh chat rooms list when returning to update unread counts
        provider.fetchChatRooms();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.paddingS),
        padding: EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: AppDimensions.shadowBlurRadius,
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: chat.profileImageUrl != null && chat.profileImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        chat.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(chat.name);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(chat.name),
            ),

            SizedBox(width: AppDimensions.paddingM),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Timestamp Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer<ChatProvider>(
                        builder: (context, provider, child) {
                          return Text(
                            provider.formatTimestamp(chat.timestamp),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Last Message Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount != null && chat.unreadCount! > 0)
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.titleMedium.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSearchResults(UserSearchProvider searchProvider) {
    if (searchProvider.isSearchingUsers) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (searchProvider.searchedUsers.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingS,
      ),
      itemCount: searchProvider.searchedUsers.length,
      itemBuilder: (context, index) {
        final user = searchProvider.searchedUsers[index];
        return _buildUserSearchItem(user, searchProvider);
      },
    );
  }

  Widget _buildUserSearchItem(ChatUser user, UserSearchProvider searchProvider) {
    return GestureDetector(
      onTap: () async {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );

        try {
          // Create chat room with the selected user using UserSearchProvider
          final room = await searchProvider.createChatRoomWithUser(user.id);
          
          // Close loading dialog
          if (context.mounted) {
            Navigator.pop(context);
          }

          if (room != null && context.mounted) {
            // Navigate to chat detail page
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  roomId: room.id,
                  contactName: user.name ?? user.email ?? 'Unknown',
                  contactProfileImageUrl: user.profileImage,
                ),
              ),
            );
            
            // Clear search and refresh chat rooms
            _searchController.clear();
            searchProvider.clearSearch();
            
            // Refresh chat rooms list using ChatProvider
            final chatProvider = Provider.of<ChatProvider>(context, listen: false);
            chatProvider.fetchChatRooms();
          } else if (context.mounted) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(searchProvider.createRoomError ?? 'Failed to create chat room. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          // Close loading dialog if still open
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.paddingS),
        padding: EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: AppDimensions.shadowBlurRadius,
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: user.profileImage != null && user.profileImage!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(user.name ?? user.email ?? '?');
                        },
                      ),
                    )
                  : _buildDefaultAvatar(user.name ?? user.email ?? '?'),
            ),

            SizedBox(width: AppDimensions.paddingM),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? user.email ?? 'Unknown',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email != null && user.name != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      user.email!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (user.role != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      user.role!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
