import 'thix_money_api.dart';

class AdminService {
  final ThixMoneyApi _api = ThixMoneyApi();

  Future<List<Map<String, dynamic>>> getPendingMerchantRequests() async {
    final data = await _api.invoke('admin/list-requests');
    return List<Map<String, dynamic>>.from(data['requests']);
  }

  Future<void> approveMerchant(String userId, String businessName) async {
    await _api.invoke('admin/approve-merchant', body: {
      'user_id': userId,
      'business_name': businessName,
    });
  }

  Future<void> rejectMerchant(String userId, String reason) async {
    await _api.invoke('admin/reject-merchant', body: {
      'user_id': userId,
      'reason': reason,
    });
  }
}
