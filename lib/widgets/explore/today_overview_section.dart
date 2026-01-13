import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'stat_card_widget.dart';

class TodayOverviewSection extends StatelessWidget {
  final int todayJobs;
  final int totalCompleted;
  final double avgRating;
  final String weeklyEarning;

  const TodayOverviewSection({
    super.key,
    required this.todayJobs,
    required this.totalCompleted,
    required this.avgRating,
    required this.weeklyEarning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: Text(
            "Today's Overview",
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
        SizedBox(height: AppDimensions.verticalSpaceM),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCardWidget(
                      icon: Icons.work_outline,
                      iconColor: AppColors.info,
                      iconBackgroundColor: AppColors.infoLight,
                      value: todayJobs.toString(),
                      label: "Today's Jobs",
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: StatCardWidget(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.primary,
                      iconBackgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      value: totalCompleted.toString(),
                      label: 'Total Completed',
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.verticalSpaceM),
              Row(
                children: [
                  Expanded(
                    child: StatCardWidget(
                      icon: Icons.star_outline,
                      iconColor: AppColors.warningDark,
                      iconBackgroundColor: AppColors.warningLight,
                      value: avgRating.toStringAsFixed(1),
                      label: 'Avg. Rating',
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: StatCardWidget(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      iconBackgroundColor: AppColors.successLight,
                      value: weeklyEarning,
                      label: 'This Week Earning',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

