import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/transfer_viewmodel.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TransferViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Envoyer de l’argent')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(labelText: 'Bénéficiaire (UID Thix ID)'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant (FC)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await vm.transfer(
                            recipientUid: _recipientController.text,
                            amount: double.parse(_amountController.text),
                          );
                          if (success && mounted) Navigator.pop(context);
                        }
                      },
                child: vm.isLoading ? const CircularProgressIndicator() : const Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
