import 'package:flutter/material.dart';
import '../../services/thix_money/balance_service.dart';
import '../../services/thix_money/transaction_service.dart';
import '../../models/thix_money/account_model.dart';
import '../../models/thix_money/transaction_model.dart';

class ThixMoneyProvider extends ChangeNotifier {
  final BalanceService _balanceService = BalanceService();
  final TransactionService _transactionService = TransactionService();

  List<AccountModel> _accounts = [];
  List<TransactionModel> _recentTransactions = [];
  List<TransactionModel> _merchantTransactions = [];
  double _todayMerchantRevenue = 0;
  double _totalBalance = 0;
  bool _isLoading = false;

  List<AccountModel> get accounts => _accounts;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  List<TransactionModel> get merchantTransactions => _merchantTransactions;
  double get todayMerchantRevenue => _todayMerchantRevenue;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final accounts = await _balanceService.getBalance();
      _accounts = accounts;
      _totalBalance = accounts.fold(0, (sum, a) => sum + a.balance);
      _recentTransactions = await _transactionService.getRecentTransactions();
    } catch (e) {
      debugPrint('ThixMoneyProvider loadData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMerchantData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _merchantTransactions = await _transactionService.getMerchantTransactions();
      _todayMerchantRevenue = _merchantTransactions
          .where((t) => t.isToday)
          .fold(0, (sum, t) => sum + t.amount);
    } catch (e) {
      debugPrint('ThixMoneyProvider loadMerchantData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
