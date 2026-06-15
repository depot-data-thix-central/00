import 'package:flutter/material.dart';
import '../theme/thix_money_theme.dart';

class ConfirmPaymentDialog extends StatelessWidget {
  final double amount;
  final String recipient;
  final VoidCallback onConfirm;

  const ConfirmPaymentDialog({
    Key? key,
    required this.amount,
    required this.recipient,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirmer le paiement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoRow('Montant', '${amount.toStringAsFixed(0)} FC'),
          const SizedBox(height: 12),
          _buildInfoRow('Bénéficiaire', recipient),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Vérifiez les informations avant de valider.',
            style: TextStyle(fontSize: 12, color: ThixMoneyTheme.textHintColor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ThixMoneyTheme.errorColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: ThixMoneyTheme.textSecondaryColor)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
