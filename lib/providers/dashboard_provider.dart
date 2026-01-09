import 'package:flutter/foundation.dart';
import '../models/dashboard/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardModel? _dashboardData;
  DashboardModel? get dashboardData => _dashboardData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Get dashboard data
  Future<void> fetchDashboard() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final dashboard = await _service.getDashboard();

      _dashboardData = dashboard;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch dashboard: ${e.toString()}';
      notifyListeners();
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await fetchDashboard();
  }
}


