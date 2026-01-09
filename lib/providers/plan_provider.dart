import 'package:flutter/foundation.dart';

class PlanProvider with ChangeNotifier {
  String? _selectedPlan = 'Starter Plan';
  bool _isLoading = false;

  String? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;

  void selectPlan(String? planName) {
    _selectedPlan = planName;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPlan = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

