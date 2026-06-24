import 'thix_money_api.dart';

class SplitPaymentService {
  final ThixMoneyApi _api = ThixMoneyApi();

  Future<String> generateSplitCode(double totalAmount) async {
    final data = await _api.invoke('split-payment/generate', body: {
      'total_amount': totalAmount,
    });
    return data['code'];
  }

  Future<bool> completeSplit(String code) async {
    try {
      await _api.invoke('split-payment/complete', body: {'code': code});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSplitsForMerchant(String merchantId) async {
    final data = await _api.invoke('split-payment/pending', body: {'merchant_id': merchantId});
    return List<Map<String, dynamic>>.from(data['splits']);
  }

  Future<void> markSplitAsCompleted(String splitCode) async {
    await _api.invoke('split-payment/mark-completed', body: {'code': splitCode});
  }
}
