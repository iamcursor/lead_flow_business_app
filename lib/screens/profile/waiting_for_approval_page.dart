import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../screens/auth/login_page.dart';
import 'dart:async';

/// Waiting for Approval Page
class WaitingForApprovalPage extends StatefulWidget {
  const WaitingForApprovalPage({super.key});

  @override
  State<WaitingForApprovalPage> createState() => _WaitingForApprovalPageState();
}

class _WaitingForApprovalPageState extends State<WaitingForApprovalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate to login screen when back button is pressed
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // Remove all previous routes
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clock Icon - Large filled circle with clock
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 40.w,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceL),
                  
                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Waiting for Approval',
                      style: AppTextStyles.appBarTitle.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  
                  // Message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                      ),
                      child: Text(
                        'We\'ve received your request and are\nwaiting for the approval. Please wait a few\nminutes.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

