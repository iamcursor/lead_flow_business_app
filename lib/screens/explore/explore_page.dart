import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/profile/profile_page.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/booking/booking_model.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../widgets/explore/available_for_work_card.dart';
import '../../widgets/explore/explore_header_widget.dart';
import '../../widgets/explore/new_job_request_card.dart';
import '../../widgets/explore/referral_bonus_card.dart';
import '../../widgets/explore/today_overview_section.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize bookings, availability, and dashboard on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      
      // Initialize availability from login response if not already set
      authProvider.initializeAvailability();
      
      // Fetch bookings
      bookingProvider.fetchBookings();
      
      // Fetch dashboard data
      dashboardProvider.fetchDashboard();
    });

    return Consumer3<AuthProvider, BookingProvider, DashboardProvider>(
      builder: (context, authProvider, bookingProvider, dashboardProvider, child) {
        final loginResponse = authProvider.response;
    
    // Extract user data from login response
    Map<String, dynamic>? user;
    Map<String, dynamic>? businessProfile;
    
    if (loginResponse != null && loginResponse['user'] != null) {
      user = loginResponse['user'] as Map<String, dynamic>?;
      if (user != null && user['business_owner_profile'] != null) {
        businessProfile = user['business_owner_profile'] as Map<String, dynamic>?;
      }
    }
    
    // Get user name
    final userName = user?['name']?.toString() ?? 
                     businessProfile?['name']?.toString() ?? 
                     'User';
    final firstName = userName.split(' ').first;
    
    // Get profile image
    final profileImageUrl = businessProfile?['recent_photo']?.toString();
    
    // Get radius (max_lead_distance_miles)
    final maxDistanceMiles = businessProfile?['max_lead_distance_miles'];
    final radiusKm = maxDistanceMiles != null 
        ? (maxDistanceMiles is int ? maxDistanceMiles.toDouble() : (maxDistanceMiles as num).toDouble()) * 1.60934
        : 10.0;

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.screenPaddingTop),
                      ExploreHeaderWidget(
                        userName: firstName,
                        profileImageUrl: profileImageUrl,
                        onProfileTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                        },
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      AvailableForWorkCard(
                        isAvailable: authProvider.isAvailableForWork,
                        radius: '${radiusKm.toStringAsFixed(1)} km radius',
                        onToggleChanged: (value) {
                          authProvider.setIsAvailableForWork(value);
                          // TODO: Update availability status via API
                        },
                      ),
                      // Get pending bookings (new job requests)
                      Builder(
                        builder: (context) {
                          final pendingBookings = bookingProvider.bookings
                              .where((booking) => booking.status.toLowerCase() == 'pending')
                              .toList();
                          
                          // Only show card if there are pending bookings
                          if (pendingBookings.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          // Get the first pending booking
                          final firstPendingBooking = pendingBookings.first;
                          
                          // Format time frame (e.g., "Today, 2:00 PM" or "Within 30 minutes")
                          String timeFrame = '${firstPendingBooking.date}, ${firstPendingBooking.time}';
                          if (firstPendingBooking.date == 'Today') {
                            timeFrame = 'Today, ${firstPendingBooking.time}';
                          }
                          
                          // Format distance
                          String distanceText = firstPendingBooking.distance ?? 'Distance not available';
                          
                          // Format price
                          String priceText = '\$${firstPendingBooking.price.toStringAsFixed(0)}';
                          
                          return NewJobRequestCard(
                            customerName: firstPendingBooking.customerName,
                            distance: distanceText,
                            serviceType: firstPendingBooking.serviceName.isNotEmpty 
                                ? firstPendingBooking.serviceName 
                                : (businessProfile?['primary_service_category']?.toString() ?? 'AC Servicing'),
                            timeFrame: timeFrame,
                            price: priceText,
                            onAccept: () async {
                              final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                              final updatedBooking = await bookingProvider.updateBookingStatus(
                                bookingId: firstPendingBooking.bookingId,
                                status: 'confirmed',
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
                                bookingId: firstPendingBooking.bookingId,
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
                          );
                        },
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      Builder(
                        builder: (context) {
                          // Use dashboard data if available, otherwise use defaults
                          final dashboardData = dashboardProvider.dashboardData;
                          
                          return TodayOverviewSection(
                            todayJobs: dashboardData?.todayJobs ?? 0,
                            totalCompleted: dashboardData?.totalCompleted ?? 0,
                            avgRating: dashboardData?.avgRating ?? 0.0,
                            weeklyEarning: dashboardData?.thisWeekEarning ?? '0',
                          );
                        },
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      ReferralBonusCard(
                        referralCount: 3,
                        bonusAmount: '\$600',
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceXL),
                    ],
                  ),
                ),
                // Centered Loader Overlay
                if (bookingProvider.isLoading || dashboardProvider.isLoading)
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

            )
            )
        );
          },
        );


  }
}
