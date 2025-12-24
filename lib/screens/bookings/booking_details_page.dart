import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/booking_provider.dart';

class BookingDetailsPage extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool _isUpdatingStatus = false;

  Future<void> _handleStartBooking() async {
    setState(() {
      _isUpdatingStatus = true;
    });

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.updateBookingStatus(
      bookingId: widget.booking.bookingId,
      status: 'in_progress',
    );

    setState(() {
      _isUpdatingStatus = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking started successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Refresh bookings list
      await bookingProvider.refreshBookings();
      // Pop back to bookings list
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Failed to start booking'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCompleteBooking() async {
    setState(() {
      _isUpdatingStatus = true;
    });

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.updateBookingStatus(
      bookingId: widget.booking.bookingId,
      status: 'completed',
    );

    setState(() {
      _isUpdatingStatus = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking completed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Refresh bookings list
      await bookingProvider.refreshBookings();
      // Pop back to bookings list
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Failed to complete booking'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                                    'New Job Requests',
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
                  
                  // Pricing & Payments Card
                  _buildPricingCard(),
                  
                  SizedBox(height: AppDimensions.verticalSpaceXL),
                          // Show button based on status
                          if (widget.booking.status.toLowerCase() == 'confirmed')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnPrimary,
                                ),
                                onPressed: _isUpdatingStatus ? null : _handleStartBooking,
                                child: Text('Start Booking', style: AppTextStyles.buttonLarge),
                              ),
                            )
                          else if (widget.booking.status.toLowerCase() == 'in_progress')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnPrimary,
                                ),
                                onPressed: _isUpdatingStatus ? null : _handleCompleteBooking,
                                child: Text('Complete Booking', style: AppTextStyles.buttonLarge),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Loader Overlay
            if (_isUpdatingStatus)
              Container(
                color: AppColors.overlayLight,
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight,
                      ),
                      strokeWidth: 2,
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
          Text(
            'Customer Info',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          // Customer Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: widget.booking.customerProfilePicture != null
                    ? NetworkImage(widget.booking.customerProfilePicture!)
                    : null,
                child: widget.booking.customerProfilePicture == null
                    ? Icon(
                        Icons.person,
                        size: AppDimensions.iconL,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              SizedBox(width: AppDimensions.paddingM),
              // Customer Name and Location - Expanded to take remaining space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.booking.customerName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXS),
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
                            widget.booking.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Distance, View on Map, and Contact Buttons in one row
          Padding(
            padding: EdgeInsets.only(top: AppDimensions.verticalSpaceS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance and View on Map on the left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.booking.distance != null)
                      Text(
                        widget.booking.distance!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to map view
                      },
                      child: Text(
                        'View on Map',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                // Contact Buttons on the right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildContactButton(
                      icon: Icons.phone,
                      onTap: () => _makePhoneCall(),
                    ),
                    SizedBox(width: AppDimensions.paddingS),
                    _buildContactButton(
                      icon: Icons.message,
                      onTap: () => _sendMessage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Color(0xffF1F4FF),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconM,
        ),
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
          // Service Type
          Text(
            widget.booking.serviceName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Appointment Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: AppDimensions.iconS,
                color: AppColors.primary,
              ),
              SizedBox(width: AppDimensions.paddingS),
              Text(
                '${widget.booking.date} at ${widget.booking.time}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Estimated Duration
          if (widget.booking.estimatedDuration != null) ...[
            Text(
              'Estimated Duration: ${widget.booking.estimatedDuration}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary
              ),
            ),
            SizedBox(height: AppDimensions.verticalSpaceS),
          ],
          // Service Notes
          Text(
            'Service Notes',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(
                width: 1,
                color: AppColors.borderDark
              )
            ),
            child: Text(
              widget.booking.serviceNotes ?? 'No notes provided',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
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
            'Pricing & Payments',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Offered Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offered Rate:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700

                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceXS),
                  Text(
                    'Incl. visit charges',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.textPrimary
                    ),
                  ),
                ],
              ),
              Text(
                '\$${widget.booking.price.toStringAsFixed(0)}',
                style: AppTextStyles.priceText.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          // Additional Charges
          Text(
            'Additional charges: additional charges can be added after job completion.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    if (widget.booking.customerPhone != null) {
      // TODO: Implement phone call functionality

    }
  }

  Future<void> _sendMessage() async {
    if (widget.booking.customerPhone != null) {
      // TODO: Implement messaging functionality

    }
  }
}

