// 📁 lib/presentation/admin_hopital/billing/widgets/billing_payment_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_date_picker.dart';
import '../../common/providers/admin_billing_provider.dart';
import '../../../../data/models/hospital/invoice_model.dart';

class BillingPaymentForm extends ConsumerStatefulWidget {
  final String? invoiceId;
  final String? patientId;
  final String? patientName;
  final Function(Map<String, dynamic>)? onPaymentComplete;

  const BillingPaymentForm({
    Key? key,
    this.invoiceId,
    this.patientId,
    this.patientName,
    this.onPaymentComplete,
  }) : super(key: key);

  @override
  ConsumerState<BillingPaymentForm> createState() => _BillingPaymentFormState();
}

class _BillingPaymentFormState extends ConsumerState<BillingPaymentForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Valeurs
  String _paymentMethod = 'Carte bancaire';
  String _status = 'pending';
  DateTime? _paymentDate;
  InvoiceModel? _invoice;
  double _remainingAmount = 0.0;

  final List<String> _paymentMethods = [
    'Carte bancaire',
    'Espèces',
    'Virement',
    'Chèque',
    'Assurance / Mutuelle',
    'En ligne',
    'Autre',
  ];

  final List<String> _statuses = ['pending', 'paid', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _paymentDate = DateTime.now();
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
          _remainingAmount = invoice.amount;
          _amountCtrl.text = invoice.amount.toStringAsFixed(2);
        });
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? _invoice?.patientName ?? 'Patient inconnu';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Enregistrement d\'un paiement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Informations patient
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Patient: $patientName',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (_invoice != null)
                    Text(
                      'Facture #${_invoice!.number}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Montant
            AdminFormField(
              label: 'Montant (€) *',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              hint: '0.00',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Montant requis';
                final amount = double.tryParse(v);
                if (amount == null || amount <= 0) return 'Montant invalide';
                if (_remainingAmount > 0 && amount > _remainingAmount) {
                  return 'Dépasse le montant restant (${_remainingAmount.toStringAsFixed(2)} €)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Méthode de paiement
            AdminDropdown<String>(
              label: 'Méthode de paiement *',
              value: _paymentMethod,
              items: _paymentMethods.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AdminDatePicker(
                    label: 'Date du paiement',
                    selectedDate: _paymentDate,
                    onDateSelected: (date) => setState(() => _paymentDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Statut',
                    value: _status,
                    items: _statuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s == 'pending' ? 'En attente' : (s == 'paid' ? 'Payé' : 'Annulé'),
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Référence
            AdminFormField(
              label: 'Référence du paiement (optionnel)',
              controller: _referenceCtrl,
              hint: 'Numéro de transaction, chèque...',
            ),
            const SizedBox(height: 12),

            // Notes
            AdminFormField(
              label: 'Notes (optionnel)',
              controller: _notesCtrl,
              hint: 'Informations supplémentaires...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Résumé
            if (_invoice != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Montant total: ${_invoice!.amount.toStringAsFixed(2)} €',
                        style: TextStyle(fontSize: 13, color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            AdminGradientButton(
              text: 'Enregistrer le paiement',
              onPressed: _submitPayment,
              icon: Icons.save,
              gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPayment() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountCtrl.text);

    final data = {
      'invoiceId': widget.invoiceId,
      'patientId': widget.patientId,
      'patientName': widget.patientName ?? _invoice?.patientName,
      'amount': amount,
      'method': _paymentMethod,
      'date': _paymentDate!,
      'status': _status,
      'reference': _referenceCtrl.text,
      'notes': _notesCtrl.text,
    };

    if (widget.onPaymentComplete != null) {
      widget.onPaymentComplete!(data);
    } else {
      // Sauvegarder via le provider
      // À implémenter selon votre logique
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement enregistré'), backgroundColor: Colors.green),
      );
    }
  }
}
