import '../common/constants/app_url.dart';
import '../common/utils/request_provider.dart';
import '../common/utils/app_excpetions.dart';
import '../models/dashboard/dashboard_model.dart';

class DashboardService {
  // Get dashboard data
  Future<DashboardModel> getDashboard() async {
    try {
      final data = await RequestProvider.get(
        url: AppUrl.dashboard,
      );

      if (data == null) {
        throw UnknownException('Get dashboard failed: No response from server');
      }

      if (data is Map<String, dynamic>) {
        return DashboardModel.fromJson(data);
      } else if (data is Map) {
        return DashboardModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw UnknownException('Invalid response format');
    } on NetworkExceptions {
      rethrow;
    } catch (e) {
      if (e is NetworkExceptions) rethrow;
      throw UnknownException('Get dashboard failed: ${e.toString()}');
    }
  }
}


