import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/screens/bookings/bookings_page.dart';
import 'package:lead_flow_business/screens/chat/chat_page.dart';
import 'package:lead_flow_business/screens/chat/chat_detail_page.dart';
import 'package:lead_flow_business/screens/earnings/earnings_page.dart';
import 'package:lead_flow_business/screens/explore/explore_page.dart';
import 'package:lead_flow_business/screens/profile/profile_page.dart';
import 'package:lead_flow_business/providers/business_owner_provider.dart';
import 'package:lead_flow_business/providers/booking_provider.dart';
import 'package:provider/provider.dart';

import '../styles/app_colors.dart';


/// Main Navigation Screen with Bottom Navigation Bar
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0, // Bookings is now the default screen
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const ExplorePage(),
    const BookingsPage(),
    const EarningsPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Fetch business owner profile automatically on login (similar to bookings)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessOwnerProvider>(context, listen: false);
      // Fetch profile if it hasn't been loaded yet
      if (provider.response == null) {
        provider.fetchBusinessOwnerProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            
            // Fetch bookings only when Bookings tab (index 1) is selected
            if (index == 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                bookingProvider.fetchBookings();
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/dashboard.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              activeIcon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/dashboard.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/task_alt.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              activeIcon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/task_alt.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/credit_card.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              activeIcon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/credit_card.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/Message 24.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              activeIcon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/Message 24.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/Frame.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              activeIcon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/Frame.png',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}