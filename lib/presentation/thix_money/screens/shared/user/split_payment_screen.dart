import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/split_payment_viewmodel.dart';
import '../../widgets/split_payment_qrcode.dart';

class SplitPaymentScreen extends StatelessWidget {
  const SplitPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SplitPaymentViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement fractionné')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (vm.generatedCode == null) ...[
              TextField(
                decoration: const InputDecoration(labelText: 'Montant total'),
                keyboardType: TextInputType.number,
                onChanged: (v) => vm.totalAmount = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async => vm.generateSplitCode(),
                child: const Text('Générer code'),
              ),
            ] else ...[
              const Text('Code de paiement fractionné :'),
              const SizedBox(height: 8),
              SplitPaymentQrCode(data: vm.generatedCode!),
              const SizedBox(height: 8),
              Text('Code : ${vm.generatedCode}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.reset(),
                child: const Text('Nouveau code'),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const Text('Compléter un paiement', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              decoration: const InputDecoration(labelText: 'Entrez le code'),
              onChanged: (v) => vm.completionCode = v,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => vm.completeSplitPayment(),
              child: const Text('Compléter'),
            ),
          ],
        ),
      ),
    );
  }
}
