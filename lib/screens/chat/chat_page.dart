import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/chat/chat_model.dart';
import 'chat_detail_page.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/chat_provider.dart';

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
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.setSearchQuery(_searchController.text);
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
      backgroundColor: AppColors.background,
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

            // Chat List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  return _buildChatList(provider);
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
                ),
              ),
            ),
          ),

          // Empty space to balance
          SizedBox(width: AppDimensions.iconM),
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
            child: SizedBox(
              height: 46.h,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.inputHint.copyWith(
                    fontSize: 16.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
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
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: AppColors.primary,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(ChatProvider provider) {
    if (provider.isLoadingChatRooms && provider.allChats.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
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
                color: AppColors.textSecondary,
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
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchChatRooms(),
      color: AppColors.primary,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
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
                color: AppColors.surfaceVariant,
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
                              color: AppColors.textSecondary,
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
                            color: AppColors.textSecondary,
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
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnPrimary,
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
          color: AppColors.primary,
        ),
      ),
    );
  }
}
