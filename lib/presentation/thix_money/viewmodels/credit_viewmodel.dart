import 'package:flutter/material.dart';
import '../../services/thix_money/credit_service.dart';

class CreditViewmodel extends ChangeNotifier {
  final CreditService _creditService = CreditService();
  double _creditLimit = 0;
  double requestedAmount = 0;
  bool _isRequesting = false;

  double get creditLimit => _creditLimit;
  bool get isRequesting => _isRequesting;

  Future<void> loadCreditLimit() async {
    final limit = await _creditService.getCreditLimit();
    _creditLimit = limit;
    notifyListeners();
  }

  Future<bool> requestCredit() async {
    if (requestedAmount <= 0 || requestedAmount > _creditLimit) return false;
    _isRequesting = true;
    notifyListeners();
    try {
      await _creditService.requestCredit(requestedAmount);
      return true;
    } catch (e) {
      debugPrint('Credit request error: $e');
      return false;
    } finally {
      _isRequesting = false;
      notifyListeners();
    }
  }
}
