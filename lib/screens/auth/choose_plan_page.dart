import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../providers/plan_provider.dart';
import '../../services/payment_service.dart';
import '../../common/constants/app_url.dart';
import '../../models/plan/plan_model.dart';
import 'stripe_checkout_page.dart';
import 'login_page.dart';

/// Choose Your Plan Page
/// Displays pricing plans for users to select
class ChoosePlanPage extends StatelessWidget {
  const ChoosePlanPage({super.key});

  static final PaymentService _paymentService = PaymentService();
  
  static final List<PlanModel> _plans = [
    PlanModel(
      name: 'Starter Plan',
      price: '\$29',
      period: '/ month',
      features: ['Limited leads', 'Basic profile', 'Auto-Matching'],
      priceId: 'price_1SpzUOJRGjtftwn6biQZHaVB', // BO Starter Plan

    ),
    PlanModel(
      name: 'Growth Plan',
      price: '\$79',
      period: '/ month',
      features: ['Higher lead volume', 'Enhanced profile', 'Analytics'],
      priceId: 'price_1SpzXmJRGjtftwn6uOrIzELW', // BO Growth Plan

    ),
    PlanModel(
      name: 'Pro Plan',
      price: '\$149',
      period: '/ month',
      features: ['Unlimited leads', 'Premium placement', 'Contact automation'],
      priceId: 'price_1SpzZkJRGjtftwn6mV7DwTJr', // BO Pro Plan

    ),

  ];

  static Future<void> _handleContinueToPay(BuildContext context, PlanProvider planProvider) async {
    final selectedPlanName = planProvider.selectedPlan;
    if (selectedPlanName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Find the selected plan
    final selectedPlan = _plans.firstWhere(
      (plan) => plan.name == selectedPlanName,
      orElse: () => _plans.first,
    );

    planProvider.setLoading(true);

    try {
      // Build success and cancel URLs
      final baseUrl = AppUrl.baseUrl;
      final successUrl = '$baseUrl/payment/success';
      final cancelUrl = '$baseUrl/payment/cancel';

      // Call the API to create checkout session with actual Stripe price ID
      final response = await _paymentService.createCheckoutSession(
        priceId: selectedPlan.priceId,
        plan: selectedPlanName,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      if (response != null && response.containsKey('checkout_url')) {
        final checkoutUrl = response['checkout_url'] as String;
        
        // Stop loading before navigating to checkout page
        planProvider.setLoading(false);
        
        // Navigate to Stripe checkout page in WebView
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StripeCheckoutPage(
              checkoutUrl: checkoutUrl,
              successUrl: successUrl,
              cancelUrl: cancelUrl,
            ),
          ),
        );

        // Handle payment result
        if (result == true) {
          // Payment successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to login page after successful payment
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        } else if (result == false) {
          // Payment cancelled
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create checkout session. Please try again.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.warning,
        ),
      );
    } finally {
      planProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundSecondary,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDimensions.screenPaddingTop),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      // Title
                      Center(
                        child: Text(
                          'Choose Your Plan',
                          style: AppTextStyles.appBarTitle.copyWith(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                      // Description
                      Center(
                        child: Text(
                          'Get trusted local services with flexible pricing plans designed to make home services easy and reliable. Upgrade anytime. Cancel anytime.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      // Plan Cards
                      ..._plans.map((plan) => _buildPlanCard(context, plan, planProvider)),
                      SizedBox(height: AppDimensions.verticalSpaceL),
                      // Continue to Pay Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                            disabledBackgroundColor: AppColors.primary,
                          ),
                          onPressed: planProvider.isLoading
                              ? null
                              : () => _handleContinueToPay(context, planProvider),
                          child: Text(
                            'Continue to Pay',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceS),
                    ],
                  ),
                ),
              ),
              // Centered Loader Overlay
              if (planProvider.isLoading)
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
        );
      },
    );
  }

  static Widget _buildPlanCard(BuildContext context, PlanModel plan, PlanProvider planProvider) {
    final isSelected = planProvider.selectedPlan == plan.name;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.verticalSpaceM),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFE3F2FD) // Light purple background when selected
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF1976D2) // Blue border when selected
              : AppColors.border,
          width: isSelected ? 1 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              planProvider.selectPlan(plan.name);
            },
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.cardPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plan Name
                        Text(
                          plan.name,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 17

                          ),
                        ),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.price,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Text(
                                plan.period,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Features
                        ...plan.features.map((feature) => Padding(
                              padding: EdgeInsets.only(
                                bottom: AppDimensions.verticalSpaceXS,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 15.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppDimensions.paddingS),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  // Radio Button
                  Radio<String>(
                    value: plan.name,
                    groupValue: planProvider.selectedPlan,
                    onChanged: (value) {
                      planProvider.selectPlan(value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          // Popular Badge in top right corner

        ],
      ),
    );
  }
}

