import '../../models/thix_money/account_model.dart';
import 'thix_money_api.dart';

class BalanceService {
  final ThixMoneyApi _api = ThixMoneyApi();

  Future<List<AccountModel>> getBalance() async {
    final data = await _api.invoke('get-balance');
    final List accountsJson = data['accounts'];
    return accountsJson.map((json) => AccountModel.fromJson(json)).toList();
  }
}
