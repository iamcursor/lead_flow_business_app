import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Custom Snackbar Types
enum SnackbarType { success, error, warning, info }

/// Beautiful Custom Snackbar Component
/// Provides consistent, attractive snackbar notifications throughout the app
class CustomSnackbar {
  CustomSnackbar._();

  /// Show a custom snackbar
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
    String? title,
  }) {
    final snackBar = _buildSnackBar(
      message: message,
      type: type,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseIcon: showCloseIcon,
      title: title,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.success,
      title: title,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show error snackbar
  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      title: title,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.warning,
      title: title,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.info,
      title: title,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Build the custom snackbar widget
  static SnackBar _buildSnackBar({
    required String message,
    required SnackbarType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseIcon = true,
    String? title,
  }) {
    final config = _getSnackbarConfig(type);

    return SnackBar(
      content: _SnackbarContent(
        message: message,
        title: title,
        type: type,
        config: config,
        showCloseIcon: showCloseIcon,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(AppDimensions.snackbarMargin),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onActionPressed,
              textColor: config.actionColor,
            )
          : null,
    );
  }

  /// Get snackbar configuration based on type
  static _SnackbarConfig _getSnackbarConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          backgroundColor: AppColors.success,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.check_circle_outline,
          actionColor: Colors.white,
          borderColor: AppColors.successLight,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          backgroundColor: AppColors.error,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.error_outline,
          actionColor: Colors.white,
          borderColor: AppColors.errorLight,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          backgroundColor: AppColors.warning,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.warning_amber_outlined,
          actionColor: Colors.white,
          borderColor: AppColors.warningLight,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          backgroundColor: AppColors.info,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.info_outline,
          actionColor: Colors.white,
          borderColor: AppColors.infoLight,
        );
    }
  }
}

/// Snackbar configuration class
class _SnackbarConfig {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final Color actionColor;
  final Color borderColor;

  const _SnackbarConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.actionColor,
    required this.borderColor,
  });
}

/// Custom snackbar content widget
class _SnackbarContent extends StatelessWidget {
  final String message;
  final String? title;
  final SnackbarType type;
  final _SnackbarConfig config;
  final bool showCloseIcon;

  const _SnackbarContent({
    required this.message,
    required this.type,
    required this.config,
    required this.showCloseIcon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.snackbarPadding),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.snackbarRadius),
        border: Border.all(
          color: config.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              config.icon,
              color: config.iconColor,
              size: AppDimensions.iconM,
            ),
          ),

          SizedBox(width: AppDimensions.paddingM),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: config.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceXS),
                ],
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: config.textColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Close icon
          if (showCloseIcon) ...[
            SizedBox(width: AppDimensions.paddingS),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: Container(
                padding: EdgeInsets.all(AppDimensions.paddingXS),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Icon(
                  Icons.close,
                  color: config.iconColor,
                  size: AppDimensions.iconS,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension for easy snackbar access from BuildContext
extension SnackbarExtension on BuildContext {
  /// Show success snackbar
  void showSuccessSnackbar(String message, {String? title}) {
    CustomSnackbar.showSuccess(context: this, message: message, title: title);
  }

  /// Show error snackbar
  void showErrorSnackbar(String message, {String? title}) {
    CustomSnackbar.showError(context: this, message: message, title: title);
  }

  /// Show warning snackbar
  void showWarningSnackbar(String message, {String? title}) {
    CustomSnackbar.showWarning(context: this, message: message, title: title);
  }

  /// Show info snackbar
  void showInfoSnackbar(String message, {String? title}) {
    CustomSnackbar.showInfo(context: this, message: message, title: title);
  }
}

/// Snackbar Helper Utilities
class SnackbarUtils {
  SnackbarUtils._();

  /// Show API error snackbar
  static void showApiError(BuildContext context, String error) {
    CustomSnackbar.showError(
      context: context,
      message: error,
      title: 'Error',
      actionLabel: 'Retry',
      onActionPressed: () {
        // Handle retry logic
      },
    );
  }

  /// Show network error snackbar
  static void showNetworkError(BuildContext context) {
    CustomSnackbar.showError(
      context: context,
      message: 'Please check your internet connection and try again.',
      title: 'Network Error',
      actionLabel: 'Retry',
      onActionPressed: () {
        // Handle retry logic
      },
    );
  }

  /// Show validation error snackbar
  static void showValidationError(BuildContext context, String message) {
    CustomSnackbar.showWarning(
      context: context,
      message: message,
      title: 'Validation Error',
    );
  }

  /// Show booking success snackbar
  static void showBookingSuccess(BuildContext context) {
    CustomSnackbar.showSuccess(
      context: context,
      message: 'Your booking has been confirmed successfully!',
      title: 'Booking Confirmed',
      actionLabel: 'View',
      onActionPressed: () {
        // Navigate to booking details
      },
    );
  }

  /// Show payment success snackbar
  static void showPaymentSuccess(BuildContext context) {
    CustomSnackbar.showSuccess(
      context: context,
      message: 'Payment completed successfully!',
      title: 'Payment Success',
    );
  }

  /// Show logout confirmation snackbar
  static void showLogoutSuccess(BuildContext context) {
    CustomSnackbar.showInfo(
      context: context,
      message: 'You have been logged out successfully.',
      title: 'Logged Out',
    );
  }
}
