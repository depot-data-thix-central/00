import 'package:flutter/material.dart';
import '../theme/thix_money_theme.dart';

class NfcPinDialog extends StatefulWidget {
  const NfcPinDialog({Key? key}) : super(key: key);

  @override
  State<NfcPinDialog> createState() => _NfcPinDialogState();
}

class _NfcPinDialogState extends State<NfcPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Code PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Veuillez saisir votre code PIN pour autoriser ce paiement.'),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: _obscure,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Code à 6 chiffres',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
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
            final pin = _pinController.text;
            if (pin.length == 6) {
              Navigator.pop(context, pin);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN invalide (6 chiffres requis)')),
              );
            }
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
