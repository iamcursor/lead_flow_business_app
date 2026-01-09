import 'package:lead_flow_business/common/constants/app_url.dart';
import 'package:lead_flow_business/common/utils/request_provider.dart';

/// Payment Service
/// Handles payment-related API calls
class PaymentService {
  /// Create a Stripe Checkout Session for subscription purchase
  /// Returns the session ID and hosted checkout URL
  Future<Map<String, dynamic>?> createCheckoutSession({
    required String priceId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final requestBody = {
        'price_id': priceId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      };

      final data = await RequestProvider.post(
        url: AppUrl.createCheckoutSession,
        body: requestBody,
      );

      if (data == null) {
        return null;
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

