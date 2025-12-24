import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'custom_toggle_switch.dart';

class AvailableForWorkCard extends StatelessWidget {
  final bool isAvailable;
  final String radius;
  final ValueChanged<bool>? onToggleChanged;

  const AvailableForWorkCard({
    super.key,
    required this.isAvailable,
    required this.radius,
    this.onToggleChanged,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available for Work',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700
                  ),
                ),
                SizedBox(height: AppDimensions.verticalSpaceS),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppDimensions.iconS,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      radius,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.verticalSpaceXS),
                Text(
                  "You're visible to the customers near you",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.paddingM),
          CustomToggleSwitch(
            value: isAvailable,
            onChanged: onToggleChanged,
          ),
        ],
      ),
    );
  }
}

