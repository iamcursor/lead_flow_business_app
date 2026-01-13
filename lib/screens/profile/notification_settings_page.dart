import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/explore/custom_toggle_switch.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Notification preferences state
  bool _enableNotifications = true;
  bool _bookingAlerts = false;
  bool _dailyUpdates = false;
  bool _generalAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.screenPaddingTop),
              
              // Back Button and Title Row
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.primary,
                      size: AppDimensions.iconM,
                    ),
                    onPressed: () =>  Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: AppTextStyles.appBarTitle.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.iconM + AppDimensions.paddingM),
                ],
              ),
              
              SizedBox(height: AppDimensions.verticalSpaceL),
              
              // Enable Notifications Card
              _buildNotificationCard(
                title: 'Enable Notifications',
                subtitle: "You'll receive daily updates",
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                },
              ),
              
              SizedBox(height: AppDimensions.verticalSpaceM),
              
              // Control Alerts, Reminder Card
              _buildNotificationCard(
                title: 'Control alerts, reminder',
                subtitle: 'Manage Bookings Alerts',
                value: _bookingAlerts,
                onChanged: (value) {
                  setState(() {
                    _bookingAlerts = value;
                  });
                },
              ),
              
              SizedBox(height: AppDimensions.verticalSpaceM),
              
              // Daily Updates Card
              _buildNotificationCard(
                title: 'Daily updates',
                subtitle: "You'll receive daily updates.",
                value: _dailyUpdates,
                onChanged: (value) {
                  setState(() {
                    _dailyUpdates = value;
                  });
                },
              ),
              
              SizedBox(height: AppDimensions.verticalSpaceM),
              
              // General Alerts Card
              _buildNotificationCard(
                title: 'General alerts',
                subtitle: 'Account & Profile',
                value: _generalAlerts,
                onChanged: (value) {
                  setState(() {
                    _generalAlerts = value;
                  });
                },
              ),
              
              SizedBox(height: AppDimensions.verticalSpaceXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.cardPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceXS),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimensions.paddingM),
            CustomToggleSwitch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

