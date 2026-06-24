import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/bill_payment_viewmodel.dart';

class BillPaymentScreen extends StatelessWidget {
  const BillPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<BillPaymentViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Payer des factures')),
      body: ListView(
        children: [
          _buildBillTile('SENELEC', Icons.flash_on, () => _payBill(context, vm, 'SENELEC')),
          _buildBillTile('Eau', Icons.water_drop, () => _payBill(context, vm, 'EAU')),
          _buildBillTile('Internet', Icons.wifi, () => _payBill(context, vm, 'INTERNET')),
        ],
      ),
    );
  }

  Widget _buildBillTile(String name, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _payBill(BuildContext context, BillPaymentViewmodel vm, String provider) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Montant $provider'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant (FC)'),
          onChanged: (v) => vm.billAmount = double.tryParse(v) ?? 0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, vm.billAmount),
            child: const Text('Payer'),
          ),
        ],
      ),
    );
    if (amount != null) {
      final success = await vm.payBill(provider, amount);
      if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facture payée')));
    }
  }
}
