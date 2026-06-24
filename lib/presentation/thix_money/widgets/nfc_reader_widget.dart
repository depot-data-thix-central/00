import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/nfc_handler.dart';
import '../dialogs/nfc_pin_dialog.dart';

class NfcReaderWidget extends StatefulWidget {
  final Function(double amount, String cardId) onPaymentSuccess;

  const NfcReaderWidget({Key? key, required this.onPaymentSuccess}) : super(key: key);

  @override
  State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
}

class _NfcReaderWidgetState extends State<NfcReaderWidget> {
  bool _isReading = false;
  final NfcHandler _nfcHandler = NfcHandler();

  @override
  void initState() {
    super.initState();
    _initNfc();
  }

  Future<void> _initNfc() async {
    final available = await _nfcHandler.isAvailable();
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC non disponible sur cet appareil')),
      );
    }
  }

  Future<void> _startReading() async {
    setState(() => _isReading = true);
    try {
      final paymentData = await _nfcHandler.readPaymentData();
      if (paymentData != null) {
        // Demander PIN si montant > seuil
        final pinValid = await showDialog<bool>(
          context: context,
          builder: (_) => const NfcPinDialog(),
        );
        if (pinValid == true) {
          widget.onPaymentSuccess(paymentData.amount, paymentData.cardId);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur NFC : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isReading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isReading ? null : _startReading,
      icon: Icon(_isReading ? Icons.hourglass_empty : Icons.nfc),
      label: Text(_isReading ? 'Lecture en cours...' : 'Approchez la carte NFC'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    );
  }
}
