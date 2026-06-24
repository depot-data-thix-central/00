import 'thix_money_api.dart';

class MerchantStatus {
  final bool isApproved;
  final bool isPending;
  final String? merchantId;
  final String? businessName;
  final String? rejectionReason;

  MerchantStatus({
    required this.isApproved,
    required this.isPending,
    this.merchantId,
    this.businessName,
    this.rejectionReason,
  });
}

class MerchantService {
  final ThixMoneyApi _api = ThixMoneyApi();

  Future<MerchantStatus> getMerchantStatus() async {
    final data = await _api.invoke('merchant/status');
    return MerchantStatus(
      isApproved: data['is_approved'],
      isPending: data['is_pending'],
      merchantId: data['merchant_id'],
      businessName: data['business_name'],
      rejectionReason: data['rejection_reason'],
    );
  }

  Future<bool> requestApproval(Map<String, dynamic> data) async {
    try {
      await _api.invoke('merchant-request', body: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getStaticQrCode(String merchantId) async {
    final data = await _api.invoke('merchant/qr-static', body: {'merchant_id': merchantId});
    return data['qr_data'];
  }

  Future<String> generateDynamicQrCode({required String merchantId, required double amount}) async {
    final data = await _api.invoke('merchant/qr-dynamic', body: {
      'merchant_id': merchantId,
      'amount': amount,
    });
    return data['qr_data'];
  }

  Future<List<Map<String, dynamic>>> getTodayTransactions(String merchantId) async {
    final data = await _api.invoke('merchant/today-transactions', body: {'merchant_id': merchantId});
    return List<Map<String, dynamic>>.from(data['transactions']);
  }
}
