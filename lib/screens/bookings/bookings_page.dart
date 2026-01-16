import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/bookings/booking_details_page.dart';
import 'package:lead_flow_business/screens/bookings/completed_booking_details_page.dart';
import 'package:provider/provider.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Don't fetch automatically - will be fetched when tab is selected in MainNavigationScreen
  }

  List<BookingModel> _getFilteredBookings(List<BookingModel> allBookings) {
    if (_selectedFilter == 'All') {
      return allBookings;
    }
    return allBookings
        .where((booking) => booking.status == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, provider, child) {
            final filteredBookings = _getFilteredBookings(provider.bookings);
            
            return Column(
              children: [
                // Main Content
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () => provider.refreshBookings(),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.screenPaddingHorizontal,
                              vertical: AppDimensions.screenPaddingVertical,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                // Title
                                Center(
                                  child: Text(
                                    'My Bookings',
                                    style: AppTextStyles.appBarTitle.copyWith(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceL),
                                
                                // Filter Buttons
                                _buildFilterButtons(),
                                
                                SizedBox(height: AppDimensions.verticalSpaceM),
                                
                                // Error State
                                if (provider.errorMessage != null && provider.bookings.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppDimensions.verticalSpaceXL,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            provider.errorMessage!,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.error,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: AppDimensions.verticalSpaceM),
                                          ElevatedButton(
                                            onPressed: () => provider.fetchBookings(),
                                            child: Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                // Empty State
                                else if (filteredBookings.isEmpty && !provider.isLoading)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppDimensions.verticalSpaceXL,
                                      ),
                                      child: Text(
                                        'No bookings found',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  )
                                // Bookings List
                                else if (filteredBookings.isNotEmpty)
                                  ...filteredBookings.map((booking) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: AppDimensions.verticalSpaceM,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to booking details based on status
                                if (booking.status.toLowerCase() == 'confirmed' || booking.status.toLowerCase() == 'in_progress') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsPage(booking: booking,),));
                                } else if (booking.status.toLowerCase() == 'completed') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedBookingDetailsPage(booking: booking),));
                                }
                              },
                              child: _BookingCard(
                                booking: booking,
                                onAccept: () async {
                                  // Show confirmation dialog
                                  final shouldConfirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                                        ),
                                        title: Text(
                                          'Confirm Job',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        content: Text(
                                          'Do you want to confirm this job?',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                                child: Text(
                                                  'No',
                                                  style: AppTextStyles.buttonMedium.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),

                                               TextButton(
                                                 onPressed: () => Navigator.of(dialogContext).pop(true),
                                                 style: TextButton.styleFrom(
                                                   backgroundColor: AppColors.primary,
                                                   foregroundColor: AppColors.textOnPrimary,
                                                   shape: RoundedRectangleBorder(
                                                     borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                                                   ),
                                                 ),
                                                 child: Text(
                                                   'Yes',
                                                   style: AppTextStyles.buttonLarge,
                                                 ),
                                               ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );

                              // Only proceed if user clicked "Yes"
                              if (shouldConfirm != true) {
                                return;
                              }

                              final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                              final updatedBooking = await bookingProvider.confirmBooking(
                                bookingId: booking.bookingId,
                              );
                                  
                                  if (updatedBooking != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Booking accepted successfully!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    // Refresh bookings to get updated list
                                    await bookingProvider.refreshBookings();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(bookingProvider.errorMessage ?? 'Failed to accept booking'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                onReject: () async {
                                  final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                                  final updatedBooking = await bookingProvider.updateBookingStatus(
                                    bookingId: booking.bookingId,
                                    status: 'rejected',
                                  );
                                  
                                  if (updatedBooking != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Booking rejected successfully!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    // Refresh bookings to get updated list
                                    await bookingProvider.refreshBookings();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(bookingProvider.errorMessage ?? 'Failed to reject booking'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                onViewDetails: () {
                                  // Navigate to booking details based on status
                                  if (booking.status.toLowerCase() == 'pending' || 
                                      booking.status.toLowerCase() == 'confirmed' || 
                                      booking.status.toLowerCase() == 'in_progress') {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsPage(booking: booking,),));
                                  } else if (booking.status.toLowerCase() == 'completed') {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedBookingDetailsPage(booking: booking),));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('View booking details'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                                  }),
                                
                                // Bottom padding for scroll
                                SizedBox(height: AppDimensions.verticalSpaceXL),
                              ],
                            ),
                          ),
                        ),
                        
                        // Centered Loader Overlay
                        if (provider.isLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['All', 'Pending', 'Completed', 'Cancelled'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: AppDimensions.paddingS),
            child: _FilterButton(
              label: filter,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetails;

  const _BookingCard({
    required this.booking,
    this.onAccept,
    this.onReject,
    this.onViewDetails,
  });

  Color _getStatusColor() {
    switch (booking.status.toLowerCase()) {
      case 'pending':
        return AppColors.warningLight;
      case 'confirmed':
        return const Color(0xFFE8E8E8); // Light grey background for confirmed status
      case 'in_progress':
        return const Color(0xFFE3F2FD);
      case 'completed':
        return const Color(0xFFC1EDC6); // Light green background from design
      case 'cancelled':
        return AppColors.errorLight;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color _getStatusTextColor() {
    switch (booking.status.toLowerCase()) {
      case 'pending':
        return AppColors.warningDark;
      case 'confirmed':
        return const Color(0xFF616161); // Grey text color for confirmed status
      case 'in_progress':
        return const Color(0xFF1976D2);
      case 'completed':
        return const Color(0xFF3FB653); // Green text color from design
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'rejected':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (booking.status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return booking.status;
    }
  }

  Color _getStatusBorderColor() {
    switch (booking.status.toLowerCase()) {
      case 'pending':
        return AppColors.warningDark;
      case 'confirmed':
        return const Color(0xFF616161); // Grey border color for confirmed status
      case 'in_progress':
        return const Color(0xFF1976D2);
      case 'completed':
        return const Color(0xFF3FB653); // Green border color from design
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'rejected':
        return AppColors.statusCancelled;
      default:
        return Colors.transparent;
    }
  }


  @override
  Widget build(BuildContext context) {
    final isPending = booking.status.toLowerCase() == 'pending';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
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
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20.r), // Highly rounded pill shape
                  border: Border.all(
                    color: _getStatusBorderColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getStatusTextColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Service Name
          Text(
            booking.serviceName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Date/Time Row with Price on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: AppDimensions.iconS,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        '${booking.date}, ${booking.time}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Price aligned to the right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${booking.price.toStringAsFixed(0)}',
                    style: AppTextStyles.priceText.copyWith(
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Location Row with "Fixed Price" on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppDimensions.iconS,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: AppDimensions.paddingS),
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
              ),
              // "Fixed Price" aligned to the right
              Text(
                booking.priceType,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          // Action Buttons
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    icon: null,
                    imagePath: 'assets/images/task_alt.png',
                    color: Theme.of(context).colorScheme.primary,
                    isOutlined: false,
                    onTap: onAccept ?? () {},
                  ),
                ),
                SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: null,
                    customIcon: _RejectIcon(),
                    color: AppColors.statusCancelled,
                    backgroundColor: AppColors.errorLight,
                    isOutlined: false,
                    onTap: onReject ?? () {},
                  ),
                ),
              ],
            )
          else if (booking.status.toLowerCase() != 'cancelled' && booking.status.toLowerCase() != 'rejected')
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: 'View Details',
                icon: null,
                color: Theme.of(context).colorScheme.primary,
                isOutlined: true,
                onTap: onViewDetails ?? () {},
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _RejectIcon extends StatelessWidget {
  const _RejectIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? imagePath;
  final Widget? customIcon;
  final Color color;
  final Color? backgroundColor;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    this.icon,
    this.imagePath,
    this.customIcon,
    required this.color,
    this.backgroundColor,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      final isLightMode = Theme.of(context).brightness == Brightness.light;
      final isViewDetailsButton = label == 'View Details';
      
      // Special styling for "View Details" button in light mode
      final backgroundColor = (isLightMode && isViewDetailsButton) 
          ? Colors.white 
          : Theme.of(context).colorScheme.surfaceVariant;
      final borderColor = (isLightMode && isViewDetailsButton)
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.outline;
      final textColor = (isLightMode && isViewDetailsButton)
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface;
      
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.paddingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                width: AppDimensions.iconS,
                height: AppDimensions.iconS,
                color: textColor,
              ),
              SizedBox(width: AppDimensions.paddingXS),
            ] else if (icon != null) ...[
              Icon(icon, size: AppDimensions.iconS, color: textColor),
              SizedBox(width: AppDimensions.paddingXS),
            ],
            Text(
              label,
              style: AppTextStyles.buttonSmall.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    // If backgroundColor is provided, use it (for reject button matching cancelled status)
    if (backgroundColor != null) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: color,
          side: BorderSide(color: color, width: 1),
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.paddingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                width: AppDimensions.iconS,
                height: AppDimensions.iconS,
                color: color,
              ),
              SizedBox(width: AppDimensions.paddingXS),
            ] else if (customIcon != null) ...[
              customIcon!,
              SizedBox(width: AppDimensions.paddingXS),
            ] else if (icon != null) ...[
              Icon(icon, size: AppDimensions.iconS, color: color),
              SizedBox(width: AppDimensions.paddingXS),
            ],
            Text(
              label,
              style: AppTextStyles.buttonSmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    // Default button style (for accept button)
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null) ...[
            Image.asset(
              imagePath!,
              width: AppDimensions.iconS,
              height: AppDimensions.iconS,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            SizedBox(width: AppDimensions.paddingXS),
          ] else if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconS, color: Theme.of(context).colorScheme.onPrimary),
            SizedBox(width: AppDimensions.paddingXS),
          ],
          Text(
            label,
            style: AppTextStyles.buttonSmall.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
