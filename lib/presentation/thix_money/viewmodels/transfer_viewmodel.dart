import 'package:flutter/material.dart';
import '../../services/thix_money/transfer_service.dart';

class TransferViewmodel extends ChangeNotifier {
  final TransferService _transferService = TransferService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> transfer({required String recipientUid, required double amount}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _transferService.transfer(recipientUid, amount);
      return true;
    } catch (e) {
      debugPrint('Transfer error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
