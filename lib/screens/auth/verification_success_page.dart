import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:lead_flow_business/screens/auth/reset_password_page.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

/// Verification Success Page
class VerificationSuccessPage extends StatefulWidget {
  final String? email;
  
  const VerificationSuccessPage({super.key, this.email});

  @override
  State<VerificationSuccessPage> createState() => _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
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

  void _navigateToNext() {
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final email = widget.email;
        if (email != null && email.isNotEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResetPasswordPage(email: email,),));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResetPasswordPage(),));
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon - Blue circle with blue fill and white checkmark
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary, // Blue fill
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary, // Blue border
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.onPrimary, // White checkmark
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceXL),
                  
                  // Congratulations Text - Blue color
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Congratulations!',
                      style: AppTextStyles.appBarTitle.copyWith(
                        color: Theme.of(context).colorScheme.primary, // Blue
                        fontWeight: FontWeight.bold,
                        fontSize: 26.w,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  
                  // Success Message - White text in dark mode
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Your verification is successful',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.onBackground, // White in dark mode
                        fontSize: 14.h
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

