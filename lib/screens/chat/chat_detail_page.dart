import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/chat/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class ChatDetailPage extends StatefulWidget {
  final String roomId; // Room ID from chat rooms API
  final String contactName;
  final String? contactProfileImageUrl;

  const ChatDetailPage({
    super.key,
    required this.roomId,
    required this.contactName,
    this.contactProfileImageUrl,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  bool _isInitialized = false;
  ChatProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save provider reference safely here
    if (_provider == null) {
      _provider = Provider.of<ChatProvider>(context, listen: false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    // Initialize provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _initializeProvider();
      }
    });
  }
  
  void _getCurrentUserId() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.response != null && authProvider.response!['user'] != null) {
      final user = authProvider.response!['user'] as Map<String, dynamic>;
      _currentUserId = user['id']?.toString();
    }
  }
  
  void _initializeProvider() {
    if (!_isInitialized && _provider != null) {
      _provider!.initialize(widget.roomId, _currentUserId).then((_) {
        // Scroll to bottom after messages are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
      _isInitialized = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Scroll to the very bottom (maxScrollExtent) to show latest messages
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        // If scroll controller doesn't have clients yet, wait a bit and try again
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Cleanup provider when leaving the page (use saved reference)
    _provider?.cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
        body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // Handle send message errors
          if (provider.sendMessageError != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.sendMessageError!),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            });
          }
          
          // Scroll to bottom when messages list changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.messages.isNotEmpty) {
              _scrollToBottom();
            }
          });
          
          return Column(
            children: [
              // Connection Status Banner
              if (provider.isConnecting || !provider.isSocketConnected)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingHorizontal,
                    vertical: AppDimensions.paddingS,
                  ),
                  color: provider.isConnecting
                      ? Colors.orange
                      : AppColors.error,
                  child: Row(
                    children: [
                      Icon(
                        provider.isConnecting
                            ? Icons.sync
                            : Icons.wifi_off,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: AppDimensions.paddingS),
                      Expanded(
                        child: Text(
                          provider.isConnecting
                              ? 'Connecting to chat server...'
                              : 'Disconnected. Messages may not be delivered.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Messages List
              Expanded(
                child: _buildMessagesList(provider),
              ),

              // Message Input
              _buildMessageInput(provider),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.shadowLight,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
              vertical: AppDimensions.paddingM,
            ),
            child: Row(
              children: [
                // Back Button
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: AppDimensions.iconM,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                SizedBox(width: AppDimensions.paddingS),

                // Profile Picture
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceVariant,
                  ),
                  child: widget.contactProfileImageUrl != null && widget.contactProfileImageUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            widget.contactProfileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar(widget.contactName);
                            },
                          ),
                        )
                      : _buildDefaultAvatar(widget.contactName),
                ),

                SizedBox(width: AppDimensions.paddingS),

                // Contact Name
                Expanded(
                  child: Text(
                    widget.contactName,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Phone Icon
                IconButton(
                  icon: Icon(
                    Icons.phone,
                    color: AppColors.primary,
                    size: AppDimensions.iconM,
                  ),
                  onPressed: () {
                    // TODO: Make phone call
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                SizedBox(width: AppDimensions.paddingXS),

                // More Options Icon
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                    size: AppDimensions.iconM,
                  ),
                  onPressed: () {
                    // TODO: Show more options
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider provider) {
    if (provider.isLoading && provider.messages.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (provider.errorMessage != null && provider.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.w,
                color: AppColors.error,
              ),
              SizedBox(height: AppDimensions.verticalSpaceM),
              Text(
                provider.errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.verticalSpaceM),
              ElevatedButton(
                onPressed: () {
                  provider.initialize(widget.roomId, _currentUserId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Build list of items (messages + date separators)
    List<_ChatItem> _buildChatItems(ChatProvider provider) {
      List<_ChatItem> items = [];
      
      for (int i = 0; i < provider.messages.length; i++) {
        final message = provider.messages[i];
        
        // Add date separator before first message or when date changes
        if (i == 0 || _shouldShowDateSeparator(provider.messages[i - 1], message)) {
          items.add(_ChatItem(isDateSeparator: true, date: message.createdAt));
        }
        
        // Add message
        items.add(_ChatItem(isDateSeparator: false, message: message, messageIndex: i));
      }
      
      // Add typing indicator if needed
      if (provider.isOtherUserTyping) {
        items.add(_ChatItem(isDateSeparator: false, isTyping: true));
      }
      
      return items;
    }

    final chatItems = _buildChatItems(provider);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingM,
      ),
      itemCount: chatItems.length,
      itemBuilder: (context, index) {
        final item = chatItems[index];
        
        if (item.isDateSeparator) {
          return _buildDateSeparator(item.date!);
        }
        
        if (item.isTyping) {
          return _buildTypingIndicator(provider);
        }
        
        final message = item.message!;
        final messageIndex = item.messageIndex!;
        final showAvatar = !message.isSentByMe &&
            (messageIndex == 0 || provider.messages[messageIndex - 1].isSentByMe || provider.messages[messageIndex - 1].senderId != message.senderId);

        return _buildMessageBubble(message, showAvatar, provider);
      },
    );
  }

  bool _shouldShowDateSeparator(MessageModel previousMessage, MessageModel currentMessage) {
    final prevDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );
    final currDate = DateTime(
      currentMessage.createdAt.year,
      currentMessage.createdAt.month,
      currentMessage.createdAt.day,
    );
    return prevDate != currDate;
  }

  String _formatDateSeparator(DateTime dateTime) {
    final localTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localTime.year, localTime.month, localTime.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      // Format as "22/12/2024" (like WhatsApp)
      return '${localTime.day}/${localTime.month}/${localTime.year}';
    }
  }

  Widget _buildDateSeparator(DateTime dateTime) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          _formatDateSeparator(dateTime),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool showAvatar, ChatProvider provider) {
    if (message.isSentByMe) {
      // Right-aligned message (sent by me)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.only(
            bottom: AppDimensions.paddingS,
            left: 60.w,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textOnPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                provider.formatMessageTime(message.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.textOnPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Left-aligned message (received)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Profile Picture (only show for first message in a group)
          if (showAvatar)
            Container(
              width: 36.w,
              height: 36.w,
              margin: EdgeInsets.only(
                right: AppDimensions.paddingS,
                bottom: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
              ),
              child: widget.contactProfileImageUrl != null && widget.contactProfileImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        widget.contactProfileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(widget.contactName);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(widget.contactName),
            )
          else
            SizedBox(width: 32.w + AppDimensions.paddingS),

          // Message Bubble
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                bottom: AppDimensions.paddingS,
                right: 60.w,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Light grey
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    provider.formatMessageTime(message.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTypingIndicator(ChatProvider provider) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppDimensions.paddingS,
          left: 0,
          right: 60.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // Light grey
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
        child: Text(
          '${widget.contactName} is typing...',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
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

  Widget _buildMessageInput(ChatProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          // Image/Gallery Icon
          Container(
            width: 42.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.image_outlined,
                color: AppColors.textSecondary,
                size: AppDimensions.iconM,
              ),
              onPressed: () {
                // TODO: Open image picker
              },
              padding: EdgeInsets.zero,
            ),
          ),

          SizedBox(width: AppDimensions.paddingS),

          // Message Input Field
          Expanded(
              child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onChanged: (text) {
                provider.onTextChanged(text);
              },
              onSubmitted: (_) {
                final content = _messageController.text.trim();
                if (content.isNotEmpty) {
                  _messageController.clear();
                  provider.sendMessage(content).then((_) {
                    _scrollToBottom();
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: AppTextStyles.inputHint.copyWith(
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
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

          SizedBox(width: AppDimensions.paddingS),

          // Send Button
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: AppColors.textOnPrimary,
                size: AppDimensions.iconM,
              ),
              onPressed: () {
                final content = _messageController.text.trim();
                if (content.isNotEmpty) {
                  _messageController.clear();
                  provider.sendMessage(content).then((_) {
                    _scrollToBottom();
                  });
                }
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class to represent chat items (messages or date separators)
class _ChatItem {
  final bool isDateSeparator;
  final bool isTyping;
  final DateTime? date;
  final MessageModel? message;
  final int? messageIndex;

  _ChatItem({
    required this.isDateSeparator,
    this.isTyping = false,
    this.date,
    this.message,
    this.messageIndex,
  });
}
