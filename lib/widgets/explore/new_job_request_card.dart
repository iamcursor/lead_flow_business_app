import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class NewJobRequestCard extends StatelessWidget {
  final String customerName;
  final String distance;
  final String serviceType;
  final String timeFrame;
  final String price;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const NewJobRequestCard({
    super.key,
    required this.customerName,
    required this.distance,
    required this.serviceType,
    required this.timeFrame,
    required this.price,
    this.onAccept,
    this.onReject,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications,
                size: AppDimensions.iconM,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: AppDimensions.paddingS),
              Text(
                'New Job Request',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$customerName, $distance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXS),
                    Text(
                      serviceType.isNotEmpty ? serviceType : 'AC Servicing',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceS),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: AppDimensions.iconS,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: AppDimensions.paddingXS),
                        Text(
                          timeFrame,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: AppTextStyles.priceText.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingS,
                      horizontal: AppDimensions.paddingM,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/task_alt.png',
                        width: AppDimensions.iconS,
                        height: AppDimensions.iconS,
                        color: Colors.white,
                      ),
                      SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        'Accept',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorLight,
                    foregroundColor: AppColors.statusCancelled,
                    side: BorderSide(
                      color: AppColors.statusCancelled,
                      width: 1,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingS,
                      horizontal: AppDimensions.paddingM,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC04040),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 12.w,
                            color: const Color(0xFFC04040),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        'Reject',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: AppColors.statusCancelled,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

