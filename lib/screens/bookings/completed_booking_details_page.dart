import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lead_flow_business/screens/bookings/bookings_page.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/business_owner_provider.dart';
import '../../providers/auth_provider.dart';

class CompletedBookingDetailsPage extends StatelessWidget {
  final BookingModel booking;
  final List<String>? serviceNotes;
  final List<Map<String, dynamic>>? extraCharges;

  const CompletedBookingDetailsPage({
    super.key,
    required this.booking,
    this.serviceNotes,
    this.extraCharges,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingHorizontal,
                    vertical: AppDimensions.screenPaddingVertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      
                      // Back Button and Title Row
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              size: AppDimensions.iconM,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Job Completed',
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
            
            // Customer Info Card
            _buildCustomerInfoCard(context),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Service Details Card
            _buildServiceDetailsCard(context),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Charges Overview Card
            _buildChargesCard(context),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Customer Feedback Card
            _buildFeedbackCard(context),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Action Buttons at the end
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Return to Dashboard Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Return to Dashboard',
                      style: AppTextStyles.buttonMedium,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.verticalSpaceS),
                // Download Invoice Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Handle download invoice
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download,
                          size: AppDimensions.iconM,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(width: AppDimensions.paddingS),
                        Text(
                          'Download Invoice',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.verticalSpaceM),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context) {
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
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Info',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXS),
                    Text(
                      '#ID: ${booking.bookingId}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC1EDC6), // Light green background from design - same as bookings page
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF3FB653), // Green border color from design - same as bookings page
                    width: 1,
                  ),
                ),
                child: Text(
                  'Completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF3FB653), // Green text color from design - same as bookings page
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Text(
            booking.customerName,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: AppDimensions.iconS,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: AppDimensions.paddingXS),
              Expanded(
                child: Text(
                  booking.location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(BuildContext context) {
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
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Text(
            booking.serviceName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
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
              SizedBox(width: AppDimensions.paddingS),
              Text(
                '${booking.date} at ${booking.time}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          if (booking.estimatedDuration != null)
            Text(
              'Estimated Duration: ${booking.estimatedDuration}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Text(
            'Service Notes',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          if (serviceNotes != null && serviceNotes!.isNotEmpty)
            ...serviceNotes!.map((note) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.verticalSpaceXS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        note,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else if (booking.completedServiceNotes != null && booking.completedServiceNotes!.isNotEmpty)
            ...booking.completedServiceNotes!.map((note) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.verticalSpaceXS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        note,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Text(
              'No service notes available',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChargesCard(BuildContext context) {
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
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charges Overview',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          if (extraCharges != null && extraCharges!.isNotEmpty)
            ...extraCharges!.map((charge) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.verticalSpaceS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      charge['label']?.toString() ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '\$${charge['amount']?.toString() ?? '0'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            })
          else if (booking.charges != null && booking.charges!.isNotEmpty)
            ...booking.charges!.map((charge) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.verticalSpaceS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      charge['label']?.toString() ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '\$${charge['amount']?.toString() ?? '0'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Text(
              'No charges available',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          Divider(
            height: AppDimensions.verticalSpaceL,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Charges',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${_calculateTotalCharges().toStringAsFixed(0)}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateTotalCharges() {
    if (extraCharges != null && extraCharges!.isNotEmpty) {
      double total = booking.price;
      for (var charge in extraCharges!) {
        final amount = charge['amount'];
        if (amount != null) {
          total += (amount is num) ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
        }
      }
      return total;
    } else if (booking.totalCharges != null) {
      return booking.totalCharges!;
    }
    return booking.price;
  }

  Widget _buildFeedbackCard(BuildContext buildContext) {
    return Consumer<BusinessOwnerProvider>(
      builder: (context, provider, child) {
        // Extract business profile from provider response
        final apiResponse = provider.response;
        Map<String, dynamic>? businessProfile;
        
        // Get data from API response
        if (apiResponse != null) {
          if (apiResponse['user'] != null) {
            final user = apiResponse['user'] as Map<String, dynamic>?;
            if (user != null && user['business_owner_profile'] != null) {
              businessProfile = user['business_owner_profile'] as Map<String, dynamic>?;
            }
          } else if (apiResponse['id'] != null || apiResponse['business_owner_profile'] != null) {
            businessProfile = apiResponse;
          }
        }
        
        // Extract rating from business profile
        double? rating;
        
        if (businessProfile != null) {
          if (businessProfile['rating'] != null) {
            rating = businessProfile['rating'] is String
                ? double.tryParse(businessProfile['rating'] as String) ?? 0.0
                : (businessProfile['rating'] as num?)?.toDouble() ?? 0.0;
          }
        }
        
        // If rating is not available from provider, try to get from AuthProvider
        if (rating == null || rating == 0.0) {
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final authResponse = authProvider.response;
            if (authResponse != null) {
              final user = authResponse['user'] as Map<String, dynamic>?;
              if (user != null && user['business_owner_profile'] != null) {
                final profile = user['business_owner_profile'] as Map<String, dynamic>?;
                if (profile != null && profile['rating'] != null) {
                  rating = profile['rating'] is String
                      ? double.tryParse(profile['rating'] as String) ?? 0.0
                      : (profile['rating'] as num?)?.toDouble() ?? 0.0;
                }
              }
            }
          } catch (e) {
            // Ignore errors
          }
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(buildContext).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: AppDimensions.shadowBlurRadius,
                offset: Offset(0, AppDimensions.shadowOffset),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Feedback',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(buildContext).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.verticalSpaceS),
              // Rating Stars - showing business owner's overall rating
              Row(
                children: List.generate(5, (index) {
                  final ratingValue = rating ?? 0.0;
                  return Icon(
                    index < ratingValue.round() ? Icons.star : Icons.star_border,
                    color: Theme.of(buildContext).colorScheme.tertiary,
                    size: AppDimensions.ratingStarSize,
                  );
                }),
              ),
              SizedBox(height: AppDimensions.verticalSpaceS),
              // Feedback Text
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: Theme.of(buildContext).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: Theme.of(buildContext).colorScheme.outline,
                  )
                ),
                child: Text(
                  booking.customerFeedback ?? 'No feedback provided',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(buildContext).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

