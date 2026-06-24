import 'package:flutter/material.dart';
import '../theme/thix_money_theme.dart';

class PinEntryDialog extends StatefulWidget {
  final Function(String pin)? onPinEntered;

  const PinEntryDialog({Key? key, this.onPinEntered}) : super(key: key);

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _pinController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Code PIN'),
      content: TextField(
        controller: _pinController,
        obscureText: _obscure,
        maxLength: 6,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Entrez votre code à 6 chiffres',
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
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
              widget.onPinEntered?.call(pin);
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code PIN invalide')),
              );
            }
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
