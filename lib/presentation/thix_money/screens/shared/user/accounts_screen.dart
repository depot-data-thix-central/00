import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/thix_money_provider.dart';
import '../../widgets/account_tile.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThixMoneyProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes comptes')),
      body: ListView(
        children: provider.accounts.map((acc) => AccountTile(account: acc)).toList(),
      ),
    );
  }
}
