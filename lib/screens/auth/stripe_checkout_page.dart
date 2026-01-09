import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../providers/plan_provider.dart';

/// Stripe Checkout Page
/// Displays Stripe checkout page in a WebView
class StripeCheckoutPage extends StatefulWidget {
  final String checkoutUrl;
  final String successUrl;
  final String cancelUrl;

  const StripeCheckoutPage({
    super.key,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  @override
  State<StripeCheckoutPage> createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Set initial loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      planProvider.setLoading(true);
    });
    _initializeWebView();
  }

  void _initializeWebView() {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            planProvider.setLoading(true);

            // Check if this is a success or cancel URL
            if (url.contains(widget.successUrl) ||
                url.contains('success') ||
                url.contains('payment/success')) {
              // Payment successful
              planProvider.setLoading(false);
              Navigator.of(context).pop(true); // Return true to indicate success
            } else if (url.contains(widget.cancelUrl) ||
                       url.contains('cancel') ||
                       url.contains('payment/cancel')) {
              // Payment cancelled
              planProvider.setLoading(false);
              Navigator.of(context).pop(false); // Return false to indicate cancellation
            }
          },
          onPageFinished: (String url) {
            planProvider.setLoading(false);
          },
          onWebResourceError: (WebResourceError error) {
            planProvider.setLoading(false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading page: ${error.description}'),
                backgroundColor: AppColors.warning,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: WebViewWidget(controller: _controller),
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
}

