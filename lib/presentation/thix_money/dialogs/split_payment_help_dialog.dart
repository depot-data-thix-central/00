import 'package:flutter/material.dart';
import '../theme/thix_money_theme.dart';

class SplitPaymentHelpDialog extends StatelessWidget {
  const SplitPaymentHelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Paiement fractionné'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment ça fonctionne ?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Vous générez un code ou QR code pour une facture.\n'
            '2. Vous l\'envoyez à une ou plusieurs personnes.\n'
            '3. Chacune peut compléter le montant restant.\n'
            '4. Le marchand reçoit la totalité en une fois.',
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Le code expire après 2h. Un même code ne peut être utilisé qu\'une seule fois.',
            style: TextStyle(fontSize: 12, color: ThixMoneyTheme.textHintColor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
