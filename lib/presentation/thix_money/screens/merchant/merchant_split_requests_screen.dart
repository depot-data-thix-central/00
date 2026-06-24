import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/services/thix_money/split_payment_service.dart';
import '../../providers/merchant_provider.dart';

class MerchantSplitRequestsScreen extends StatefulWidget {
  const MerchantSplitRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantSplitRequestsScreen> createState() => _MerchantSplitRequestsScreenState();
}

class _MerchantSplitRequestsScreenState extends State<MerchantSplitRequestsScreen> {
  final SplitPaymentService _splitService = SplitPaymentService();
  List<Map<String, dynamic>> _pendingSplits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingSplits();
  }

  Future<void> _loadPendingSplits() async {
    final merchantProv = Provider.of<MerchantProvider>(context, listen: false);
    final splits = await _splitService.getPendingSplitsForMerchant(merchantProv.merchantId!);
    setState(() {
      _pendingSplits = splits;
      _loading = false;
    });
  }

  Future<void> _confirmCompletion(String splitCode) async {
    try {
      await _splitService.markSplitAsCompleted(splitCode);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement complété confirmé')));
      _loadPendingSplits();
    } catch (e) {
      debugPrint('MerchantSplitRequestsScreen: markSplitAsCompleted failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de confirmation du paiement')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes de paiement fractionné')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendingSplits.isEmpty
              ? const Center(child: Text('Aucune demande en attente'))
              : ListView.builder(
                  itemCount: _pendingSplits.length,
                  itemBuilder: (ctx, i) {
                    final split = _pendingSplits[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Code: ${split['code']}'),
                        subtitle: Text('Montant total: ${split['total_amount']} FC - Restant: ${split['remaining']} FC'),
                        trailing: ElevatedButton(
                          onPressed: () => _confirmCompletion(split['code']),
                          child: const Text('Confirmer complété'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
