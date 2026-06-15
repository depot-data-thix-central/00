import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/currency_exchange_viewmodel.dart';

class CurrencyExchangeScreen extends StatelessWidget {
  const CurrencyExchangeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CurrencyExchangeViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Change de devises')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('USD → FC'),
                    Text('1 USD = ${vm.exchangeRate} FC', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: vm.fromCurrency,
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'FC', child: Text('FC')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
              ],
              onChanged: (v) => vm.fromCurrency = v!,
              decoration: const InputDecoration(labelText: 'De'),
            ),
            DropdownButtonFormField<String>(
              value: vm.toCurrency,
              items: const [
                DropdownMenuItem(value: 'FC', child: Text('FC')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
              ],
              onChanged: (v) => vm.toCurrency = v!,
              decoration: const InputDecoration(labelText: 'Vers'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Montant'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.amount = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async => vm.exchange(),
              child: const Text('Échanger'),
            ),
          ],
        ),
      ),
    );
  }
}
