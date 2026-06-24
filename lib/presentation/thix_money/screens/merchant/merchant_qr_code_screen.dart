import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/merchant_provider.dart';
import '../../services/thix_money/merchant_service.dart';
import '../../widgets/split_payment_qrcode.dart';
import '../../theme/thix_money_theme.dart';

class MerchantQrCodeScreen extends StatefulWidget {
  const MerchantQrCodeScreen({Key? key}) : super(key: key);

  @override
  State<MerchantQrCodeScreen> createState() => _MerchantQrCodeScreenState();
}

class _MerchantQrCodeScreenState extends State<MerchantQrCodeScreen> {
  String _qrData = '';
  double _amount = 0;
  final _amountController = TextEditingController();
  final MerchantService _merchantService = MerchantService();

  @override
  void initState() {
    super.initState();
    _loadStaticQr();
  }

  Future<void> _loadStaticQr() async {
    final merchantProv = Provider.of<MerchantProvider>(context, listen: false);
    final data = await _merchantService.getStaticQrCode(merchantProv.merchantId!);
    setState(() => _qrData = data);
  }

  Future<void> _generateDynamicQr() async {
    final merchantProv = Provider.of<MerchantProvider>(context, listen: false);
    final data = await _merchantService.generateDynamicQrCode(
      merchantId: merchantProv.merchantId!,
      amount: _amount,
    );
    setState(() => _qrData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code de paiement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Scannez pour payer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    if (_qrData.isNotEmpty)
                      SplitPaymentQrCode(data: _qrData, size: 200),
                    const SizedBox(height: 16),
                    const Text('QR Code marchand', style: TextStyle(color: ThixMoneyTheme.textSecondaryColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Générer un QR code avec montant fixe',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (FC)'),
              onChanged: (v) => _amount = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _amount > 0 ? _generateDynamicQr : null,
              child: const Text('Générer QR dynamique'),
            ),
          ],
        ),
      ),
    );
  }
}
