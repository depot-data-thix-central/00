import 'thix_money_api.dart';

class TransferService {
  final ThixMoneyApi _api = ThixMoneyApi();

  Future<void> transfer(String recipientUid, double amount) async {
    await _api.invoke('transfer', body: {
      'recipient_uid': recipientUid,
      'amount': amount,
    });
  }
}
