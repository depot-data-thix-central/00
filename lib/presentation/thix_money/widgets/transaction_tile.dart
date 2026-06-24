import 'package:flutter/material.dart';
import '../../models/thix_money/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final bool showMerchantView;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.showMerchantView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type == 'credit';
    final color = isPositive ? Colors.green : Colors.red;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          isPositive ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 20,
        ),
      ),
      title: Text(transaction.label),
      subtitle: Text(transaction.formattedDate),
      trailing: Text(
        '${isPositive ? '+' : '-'} ${transaction.amount.toStringAsFixed(0)} ${transaction.currency}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
