import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/thix_money_provider.dart';
import '../../widgets/transaction_tile.dart';

class MerchantTransactionsScreen extends StatelessWidget {
  const MerchantTransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThixMoneyProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements reçus')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.merchantTransactions.length,
              itemBuilder: (ctx, i) => TransactionTile(
                transaction: provider.merchantTransactions[i],
                showMerchantView: true,
              ),
            ),
    );
  }
}
