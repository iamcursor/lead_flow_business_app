import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lead_flow_business/providers/auth_provider.dart';
import 'package:lead_flow_business/providers/booking_provider.dart';
import 'package:lead_flow_business/providers/business_owner_provider.dart';
import 'package:lead_flow_business/providers/earnings_provider.dart';
import 'package:lead_flow_business/providers/chat_provider.dart';
import 'package:lead_flow_business/screens/splash/splash_page.dart';
import 'package:lead_flow_business/styles/theme.dart';

import 'package:provider/provider.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // // Initialize FCM service
  // NotificationService().requestNotificationPermission();
  // NotificationService().isTokenRefresh();
  // NotificationService().getFcmToken();

  // Initialize API client with stored token if available
  // await _initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessOwnerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => EarningsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        // ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialize app - load stored token and set it in API client
// Future<void> _initializeApp() async {
//   try {
//     final token = await StorageService.instance.getToken();
//     if (token != null && token.isNotEmpty) {
//       ApiClient.instance.setAuthToken(token);
//     }
//   } catch (e) {
//     // Handle error silently or log it
//     debugPrint('Error initializing app: $e');
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'LeadFlow Business',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const SplashPage(),
        );
      },
    );
  }
}
