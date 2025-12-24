import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class ReferralBonusCard extends StatelessWidget {
  final int referralCount;
  final String bonusAmount;

  const ReferralBonusCard({
    super.key,
    required this.referralCount,
    required this.bonusAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingS,
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.categoryIconSize * 1.0,
            height: AppDimensions.categoryIconSize * 1.0,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppDimensions.categoryIconRadius),
            ),
            child: Icon(
              Icons.card_giftcard,
              size: AppDimensions.iconL,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral bonus',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppDimensions.verticalSpaceXS),
                Text(
                  "You've earned $referralCount referrals this week, $bonusAmount in bonus!",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

