import 'package:flutter/material.dart';
import '../../models/thix_money/account_model.dart';

class AccountTile extends StatelessWidget {
  final AccountModel account;

  const AccountTile({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (account.type.toLowerCase()) {
      case 'epargne':
        icon = Icons.savings;
        break;
      case 'usd':
        icon = Icons.attach_money;
        break;
      case 'prepayee':
        icon = Icons.credit_card;
        break;
      default:
        icon = Icons.account_balance_wallet;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2D6A4F).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF2D6A4F)),
        ),
        title: Text(
          account.typeName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(account.currency),
        trailing: Text(
          '${account.balance.toStringAsFixed(0)} ${account.currency}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
