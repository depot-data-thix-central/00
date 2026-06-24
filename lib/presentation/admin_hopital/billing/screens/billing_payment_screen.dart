// 📁 lib/presentation/admin_hopital/billing/screens/billing_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/billing_payment_form.dart';
import '../widgets/billing_invoice_item.dart';
import '../../common/providers/admin_billing_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../../../data/models/hospital/invoice_model.dart';

class BillingPaymentScreen extends ConsumerStatefulWidget {
  final String? invoiceId;

  const BillingPaymentScreen({
    Key? key,
    this.invoiceId,
  }) : super(key: key);

  @override
  ConsumerState<BillingPaymentScreen> createState() => _BillingPaymentScreenState();
}

class _BillingPaymentScreenState extends ConsumerState<BillingPaymentScreen> {
  InvoiceModel? _invoice;
  bool _isLoading = true;
  bool _paymentRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    if (widget.invoiceId != null) {
      final state = ref.read(adminBillingProvider);
      final invoice = state.invoices.firstWhere(
        (inv) => inv.id == widget.invoiceId,
        orElse: () => null,
      );
      if (invoice != null) {
        setState(() {
          _invoice = invoice;
          _isLoading = false;
        });
      } else {
        // Recharger les données
        await ref.read(adminBillingProvider.notifier).loadBillingData();
        final newState = ref.read(adminBillingProvider);
        final found = newState.invoices.firstWhere(
          (inv) => inv.id == widget.invoiceId,
          orElse: () => null,
        );
        if (found != null) {
          setState(() {
            _invoice = found;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.invoiceId != null && _invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Facture non trouvée')),
        body: const Center(child: Text('Cette facture n\'existe pas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _invoice != null ? 'Paiement - Facture #${_invoice!.number}' : 'Enregistrement d\'un paiement',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_paymentRegistered)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Afficher la facture si elle existe
            if (_invoice != null) ...[
              BillingInvoiceItem(
                invoice: _invoice!,
                onTap: null,
                onPay: null,
                onPrint: null,
              ),
              const SizedBox(height: 16),
            ],

            // Formulaire de paiement
            BillingPaymentForm(
              invoiceId: widget.invoiceId,
              patientId: _invoice?.patientId,
              patientName: _invoice?.patientName,
              onPaymentComplete: (data) async {
                setState(() => _paymentRegistered = true);
                // Mettre à jour la facture si elle existe
                if (_invoice != null) {
                  // Marquer comme payée via le provider
                  final success = await ref.read(adminBillingProvider.notifier)
                      .markAsPaid(_invoice!.id);
                  if (success) {
                    // Recharger les données
                    await ref.read(adminBillingProvider.notifier).loadBillingData();
                    _loadInvoice();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paiement enregistré avec succès'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors du paiement'), backgroundColor: Colors.red),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paiement enregistré'), backgroundColor: Colors.green),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Actions supplémentaires
            if (_paymentRegistered)
              AdminGradientButton(
                text: 'Voir la facture',
                onPressed: () {
                  if (_invoice != null) {
                    context.push('/admin/billing/${_invoice!.id}');
                  } else {
                    context.pop();
                  }
                },
                icon: Icons.receipt,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
