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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: Container(
                color: AppColors.background,
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
                              color: AppColors.primary,
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.iconM + AppDimensions.paddingM),
                        ],
                      ),
                      
                      SizedBox(height: AppDimensions.verticalSpaceL),
            
            // Customer Info Card
            _buildCustomerInfoCard(),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Service Details Card
            _buildServiceDetailsCard(),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Charges Overview Card
            _buildChargesCard(),
            
            SizedBox(height: AppDimensions.verticalSpaceM),
            
            // Customer Feedback Card
            _buildFeedbackCard(),
            
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
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
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1),
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
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppDimensions.paddingS),
                        Text(
                          'Download Invoice',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.primary,
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

  Widget _buildCustomerInfoCard() {
    return Container(
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
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXS),
                    Text(
                      '#ID: ${booking.bookingId}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
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
                  color: Color(0xFFC1EDC6),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF3FB653),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF3FB653),
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
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: AppDimensions.iconS,
                color: AppColors.primaryLight,
              ),
              SizedBox(width: AppDimensions.paddingXS),
              Expanded(
                child: Text(
                  booking.location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Container(
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
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Text(
            booking.serviceName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: AppDimensions.iconS,
                color: AppColors.primary,
              ),
              SizedBox(width: AppDimensions.paddingS),
              Text(
                '${booking.date} at ${booking.time}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          if (booking.estimatedDuration != null)
            Text(
              'Estimated Duration: ${booking.estimatedDuration}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Text(
            'Service Notes',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
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
                          color: AppColors.textPrimary,
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
                          color: AppColors.textPrimary,
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
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChargesCard() {
    return Container(
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
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charges Overview',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${charge['amount']?.toString() ?? '0'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${charge['amount']?.toString() ?? '0'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
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
                color: AppColors.textSecondary,
              ),
            ),
          Divider(
            height: AppDimensions.verticalSpaceL,
            thickness: 1,
            color: AppColors.border,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Charges',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${_calculateTotalCharges().toStringAsFixed(0)}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
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

  Widget _buildFeedbackCard() {
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
          padding: EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Feedback',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppDimensions.verticalSpaceS),
              // Rating Stars - showing business owner's overall rating
              Row(
                children: List.generate(5, (index) {
                  final ratingValue = rating ?? 0.0;
                  return Icon(
                    index < ratingValue.round() ? Icons.star : Icons.star_border,
                    color: AppColors.ratingActive,
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
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: AppColors.borderDark
                  )
                ),
                child: Text(
                  booking.customerFeedback ?? 'No feedback provided',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
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

