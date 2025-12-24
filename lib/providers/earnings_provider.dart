import 'package:flutter/foundation.dart';
import '../models/earnings/earnings_model.dart';
import '../services/earnings_service.dart';


class EarningsProvider with ChangeNotifier {
  final EarningsService _service = EarningsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  EarningsSummary? _earningsSummary;
  EarningsSummary? get earningsSummary => _earningsSummary;

  List<DailyEarning> _dailyEarnings = [];
  List<DailyEarning> get dailyEarnings => List.unmodifiable(_dailyEarnings);

  List<JobEarning> _jobEarnings = [];
  List<JobEarning> get jobEarnings => List.unmodifiable(_jobEarnings);

  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Get all earnings
  Future<void> fetchEarnings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API delay
      await Future.delayed(Duration(seconds: 1));

      // Dummy data for design preview
      _earningsSummary = EarningsSummary(
        totalEarnings: 14350.0,
        averagePerJob: 395.0,
        pendingPayouts: 2195.0,
        jobsCompleted: 36,
      );

      // Dummy daily earnings data
      _dailyEarnings = [
        DailyEarning(date: '2025-06-01', amount: 600.0),
        DailyEarning(date: '2025-06-02', amount: 900.0),
        DailyEarning(date: '2025-06-03', amount: 300.0),
        DailyEarning(date: '2025-06-04', amount: 1200.0),
        DailyEarning(date: '2025-06-05', amount: 800.0),
        DailyEarning(date: '2025-06-06', amount: 1100.0),
        DailyEarning(date: '2025-06-07', amount: 750.0),
        DailyEarning(date: '2025-06-08', amount: 950.0),
        DailyEarning(date: '2025-06-09', amount: 1050.0),
      ];

      // Dummy job earnings data
      _jobEarnings = [
        JobEarning(
          jobTitle: 'Washing Machine Repair',
          date: 'June 7, 2025',
          time: '11:30 AM',
          amount: 250.0,
          status: 'Paid',
        ),
        JobEarning(
          jobTitle: 'AC Installation',
          date: 'June 6, 2025',
          time: '2:15 PM',
          amount: 450.0,
          status: 'Pending',
        ),
        JobEarning(
          jobTitle: 'Plumbing Repair',
          date: 'June 5, 2025',
          time: '9:00 AM',
          amount: 180.0,
          status: 'Paid',
        ),
        JobEarning(
          jobTitle: 'Electrical Wiring',
          date: 'June 4, 2025',
          time: '3:45 PM',
          amount: 320.0,
          status: 'Paid',
        ),
        JobEarning(
          jobTitle: 'Refrigerator Service',
          date: 'June 3, 2025',
          time: '10:20 AM',
          amount: 200.0,
          status: 'Pending',
        ),
      ];

      _walletBalance = 2150.0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch earnings: ${e.toString()}';
      notifyListeners();
    }
  }

  // Refresh earnings
  Future<void> refreshEarnings() async {
    await fetchEarnings();
  }
}

