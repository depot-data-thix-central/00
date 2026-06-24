import 'thix_money_api.dart';

class NfcPaymentService {
  final ThixMoneyApi _api = ThixMoneyApi();

  Future<bool> processNfcPayment(double amount, String cardId, String pin) async {
    try {
      await _api.invoke('nfc-pay', body: {
        'amount': amount,
        'card_id': cardId,
        'pin': pin,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
