import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/credit_viewmodel.dart';

class CreditScreen extends StatelessWidget {
  const CreditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CreditViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crédit instantané')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Votre limite', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${vm.creditLimit} FC', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Disponible', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Montant souhaité'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.requestedAmount = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async => vm.requestCredit(),
              child: const Text('Demander crédit'),
            ),
          ],
        ),
      ),
    );
  }
}
