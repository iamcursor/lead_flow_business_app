import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/profile/profile_page.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking/booking_model.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../widgets/explore/available_for_work_card.dart';
import '../../widgets/explore/explore_header_widget.dart';
import '../../widgets/explore/new_job_request_card.dart';
import '../../widgets/explore/referral_bonus_card.dart';
import '../../widgets/explore/today_overview_section.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _isAvailableForWork = true;

  @override
  void initState() {
    super.initState();
    // Initialize availability status from login response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loginResponse = authProvider.response;
      if (loginResponse != null && loginResponse['user'] != null) {
        final user = loginResponse['user'] as Map<String, dynamic>?;
        if (user != null && user['business_owner_profile'] != null) {
          final businessProfile = user['business_owner_profile'] as Map<String, dynamic>?;
          final availabilityStatus = businessProfile?['availability_status']?.toString() ?? 'available';
          setState(() {
            _isAvailableForWork = availabilityStatus.toLowerCase() == 'available';
          });
        }
      }
      // Fetch bookings to check for new job requests
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, child) {
            return Stack(
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
                        isAvailable: _isAvailableForWork,
                        radius: '${radiusKm.toStringAsFixed(1)} km radius',
                        onToggleChanged: (value) {
                          setState(() {
                            _isAvailableForWork = value;
                          });
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
                      TodayOverviewSection(
                        todayJobs: 4,
                        totalCompleted: businessProfile?['review_count'] is int 
                            ? businessProfile!['review_count'] as int
                            : (businessProfile?['review_count'] is num 
                                ? (businessProfile!['review_count'] as num).toInt() 
                                : 0),
                        avgRating: businessProfile?['rating'] != null
                            ? (businessProfile!['rating'] is String
                                ? double.tryParse(businessProfile['rating'] as String) ?? 0.0
                                : (businessProfile['rating'] as num?)?.toDouble() ?? 0.0)
                            : 0.0,
                        weeklyEarning: '\$3,200',
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
                if (bookingProvider.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
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
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
