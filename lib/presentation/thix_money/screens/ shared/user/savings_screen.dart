import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/savings_viewmodel.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SavingsViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Épargne')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Solde épargne', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${vm.savingsBalance} FC', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Montant à épargner'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.amountToSave = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => vm.saveMoney(),
              child: const Text('Épargner maintenant'),
            ),
            const Divider(),
            const Text('Objectifs', style: TextStyle(fontWeight: FontWeight.bold)),
            ...vm.savingGoals.map((goal) => ListTile(title: Text(goal.name), subtitle: Text('${goal.current}/${goal.target} FC'))),
          ],
        ),
      ),
    );
  }
}
