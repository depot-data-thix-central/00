import 'package:flutter/material.dart';
import '../../services/thix_money/split_payment_service.dart';

class SplitPaymentViewmodel extends ChangeNotifier {
  final SplitPaymentService _splitService = SplitPaymentService();
  String? _generatedCode;
  double totalAmount = 0;
  String completionCode = '';

  String? get generatedCode => _generatedCode;

  Future<void> generateSplitCode() async {
    if (totalAmount <= 0) return;
    final code = await _splitService.generateSplitCode(totalAmount);
    _generatedCode = code;
    notifyListeners();
  }

  Future<void> completeSplitPayment() async {
    if (completionCode.isEmpty) return;
    final success = await _splitService.completeSplit(completionCode);
    if (success) {
      // Optionally refresh UI
    }
    notifyListeners();
  }

  void reset() {
    _generatedCode = null;
    totalAmount = 0;
    completionCode = '';
    notifyListeners();
  }
}
