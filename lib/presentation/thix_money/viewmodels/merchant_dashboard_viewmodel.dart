import 'package:flutter/material.dart';
import '../../services/thix_money/merchant_service.dart';
import '../../models/thix_money/transaction_model.dart';

class MerchantDashboardViewmodel extends ChangeNotifier {
  final MerchantService _merchantService = MerchantService();
  List<TransactionModel> _todayTransactions = [];
  double _totalRevenueToday = 0;
  bool _isLoading = false;

  List<TransactionModel> get todayTransactions => _todayTransactions;
  double get totalRevenueToday => _totalRevenueToday;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData(String merchantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _todayTransactions = await _merchantService.getTodayTransactions(merchantId);
      _totalRevenueToday = _todayTransactions.fold(0, (sum, t) => sum + t.amount);
    } catch (e) {
      debugPrint('Dashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
