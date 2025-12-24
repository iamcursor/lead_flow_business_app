import 'package:flutter/material.dart';
import 'package:lead_flow_business/screens/profile/profile_page.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
        child: SingleChildScrollView(
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
              NewJobRequestCard(
                customerName: 'Alex Knight',
                distance: '2.5 km away',
                serviceType: businessProfile?['primary_service_category']?.toString() ?? 'AC Servicing',
                timeFrame: 'Within 30 minutes.',
                price: '\$500',
                onAccept: () {
                  // TODO: Handle accept job
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job accepted!')),
                  );
                },
                onReject: () {
                  // TODO: Handle reject job
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job rejected')),
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
      ),
    );
  }
}
