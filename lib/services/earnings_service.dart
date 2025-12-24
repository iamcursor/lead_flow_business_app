import 'package:lead_flow_business/common/constants/app_url.dart';

import '../common/utils/request_provider.dart';
import '../common/utils/app_excpetions.dart';


class EarningsService {
  // Get all earnings for the business owner
  Future<Map<String, dynamic>> getEarnings() async {
    try {
      final data = await RequestProvider.get(
        url: AppUrl.earnings,
      );

      if (data == null) {
        throw UnknownException('Get earnings failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return data;
      }
      throw UnknownException('Invalid response format');
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Get earnings failed: ${e.toString()}');
    }
  }
}
