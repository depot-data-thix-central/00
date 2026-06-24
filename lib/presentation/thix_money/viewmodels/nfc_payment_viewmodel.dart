import 'package:flutter/material.dart';
import '../../services/thix_money/nfc_payment_service.dart';

class NfcPaymentViewmodel extends ChangeNotifier {
  final NfcPaymentService _nfcService = NfcPaymentService();
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<bool> processPayment(double amount, String cardId, String pin) async {
    _isProcessing = true;
    notifyListeners();
    try {
      final success = await _nfcService.processNfcPayment(amount, cardId, pin);
      return success;
    } catch (e) {
      debugPrint('NFC payment error: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
