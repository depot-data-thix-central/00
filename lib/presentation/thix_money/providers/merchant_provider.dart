import 'package:flutter/material.dart';
import '../../services/thix_money/merchant_service.dart';

class MerchantProvider extends ChangeNotifier {
  final MerchantService _merchantService = MerchantService();
  
  bool _isMerchantMode = false;
  bool _isApproved = false;
  bool _isPending = false;
  String? _merchantId;
  String? _businessName;
  String? _rejectionReason;

  bool get isMerchantMode => _isMerchantMode;
  bool get isApproved => _isApproved;
  bool get isPending => _isPending;
  String? get merchantId => _merchantId;
  String? get businessName => _businessName;
  String? get rejectionReason => _rejectionReason;

  Future<void> loadMerchantStatus() async {
    try {
      final status = await _merchantService.getMerchantStatus();
      _isApproved = status.isApproved;
      _isPending = status.isPending;
      _merchantId = status.merchantId;
      _businessName = status.businessName;
      _rejectionReason = status.rejectionReason;
      if (!_isApproved) _isMerchantMode = false;
      notifyListeners();
    } catch (e) {
      debugPrint('MerchantProvider loadMerchantStatus error: $e');
    }
  }

  void switchMode() {
    if (!_isApproved) return;
    _isMerchantMode = !_isMerchantMode;
    notifyListeners();
  }

  Future<bool> requestMerchantApproval(Map<String, dynamic> data) async {
    try {
      final success = await _merchantService.requestApproval(data);
      if (success) {
        _isPending = true;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('MerchantProvider requestMerchantApproval error: $e');
      return false;
    }
  }

  Future<void> resetMerchantMode() async {
    _isMerchantMode = false;
    notifyListeners();
  }
}
