import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/tontine_viewmodel.dart';

class TontineScreen extends StatelessWidget {
  const TontineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TontineViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ma Tontine')),
      body: ListView(
        children: [
          ...vm.tontines.map((tontine) => ListTile(
                title: Text(tontine.name),
                subtitle: Text('Cotisation: ${tontine.contribution} FC - Tour: ${tontine.currentRound}'),
                trailing: ElevatedButton(
                  onPressed: () => vm.payContribution(tontine.id),
                  child: const Text('Payer'),
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCreateTontineDialog(context, vm),
            child: const Text('Créer une tontine'),
          ),
        ],
      ),
    );
  }

  void _showCreateTontineDialog(BuildContext context, TontineViewmodel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle tontine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onChanged: (v) => vm.newTontineName = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Cotisation (FC)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.newTontineContribution = double.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await vm.createTontine();
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
