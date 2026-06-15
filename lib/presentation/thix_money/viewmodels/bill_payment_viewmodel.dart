import 'package:flutter/material.dart';
import '../../services/thix_money/bill_payment_service.dart';

class BillPaymentViewmodel extends ChangeNotifier {
  final BillPaymentService _billService = BillPaymentService();
  double billAmount = 0;
  bool _isPaying = false;

  bool get isPaying => _isPaying;

  Future<bool> payBill(String provider, double amount) async {
    if (amount <= 0) return false;
    _isPaying = true;
    notifyListeners();
    try {
      await _billService.payBill(provider, amount);
      return true;
    } catch (e) {
      debugPrint('Bill payment error: $e');
      return false;
    } finally {
      _isPaying = false;
      notifyListeners();
    }
  }
}
