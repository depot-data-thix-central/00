import 'package:flutter/material.dart';
import '../../providers/merchant_provider.dart';

// Ce viewmodel est essentiellement un wrapper autour du provider.
// Vous pouvez le supprimer si vous utilisez directement MerchantProvider.
// Mais pour compléter la structure, voici un exemple minimal.

class MerchantModeViewmodel extends ChangeNotifier {
  final MerchantProvider _merchantProvider;

  MerchantModeViewmodel(this._merchantProvider);

  bool get isMerchantMode => _merchantProvider.isMerchantMode;
  bool get isApproved => _merchantProvider.isApproved;
  bool get isPending => _merchantProvider.isPending;

  void switchMode() => _merchantProvider.switchMode();

  Future<void> requestApproval(Map<String, dynamic> data) async {
    await _merchantProvider.requestMerchantApproval(data);
  }
}
