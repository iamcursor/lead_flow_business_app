import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class ExploreHeaderWidget extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;

  const ExploreHeaderWidget({
    super.key,
    required this.userName,
    this.profileImageUrl,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $userName',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: AppDimensions.verticalSpaceXS),
                Text(
                  "Here's what's happening today.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.paddingM),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: AppDimensions.avatarM,
              height: AppDimensions.avatarM,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                image: profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: AppDimensions.iconL,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

