// 📁 lib/presentation/admin_hopital/billing/widgets/billing_invoice_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_confirm_dialog.dart';
import '../../common/providers/admin_billing_provider.dart';
import '../../../../data/models/hospital/invoice_model.dart';

class BillingInvoiceItem extends ConsumerStatefulWidget {
  final InvoiceModel invoice;
  final VoidCallback? onTap;
  final VoidCallback? onPay;
  final VoidCallback? onPrint;

  const BillingInvoiceItem({
    Key? key,
    required this.invoice,
    this.onTap,
    this.onPay,
    this.onPrint,
  }) : super(key: key);

  @override
  ConsumerState<BillingInvoiceItem> createState() => _BillingInvoiceItemState();
}

class _BillingInvoiceItemState extends ConsumerState<BillingInvoiceItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final isPaid = invoice.status == 'paid';
    final isPending = invoice.status == 'pending';
    final isCancelled = invoice.status == 'cancelled';

    Color statusColor;
    if (isPaid) statusColor = Colors.green;
    else if (isPending) statusColor = Colors.orange;
    else if (isCancelled) statusColor = Colors.red;
    else statusColor = Colors.grey;

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPaid ? Colors.green.shade200 : (isPending ? Colors.orange.shade200 : Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: isPaid ? Colors.green.withOpacity(0.03) : Colors.grey.withOpacity(0.02),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne principale
            Row(
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle : (isPending ? Icons.pending : Icons.cancel),
                    size: 22,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 14),
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facture #${invoice.number}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        invoice.patientName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Montant et statut
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${invoice.amount.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AdminStatusBadge(
                      status: isPaid ? StatusType.completed : (isPending ? StatusType.pending : StatusType.cancelled),
                      customLabel: isPaid ? 'Payée' : (isPending ? 'En attente' : 'Annulée'),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            // Détails étendus
            if (_isExpanded) ...[
              const Divider(height: 20),
              // Détails des items
              const Text(
                'Détails de la facture',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...invoice.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '${item.quantity}x ${item.unitPrice.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.total.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${invoice.amount.toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (invoice.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${invoice.notes}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 12),
              // Actions
              Row(
                children: [
                  if (isPending && widget.onPay != null)
                    Expanded(
                      child: AdminGradientButton(
                        text: 'Marquer comme payée',
                        onPressed: widget.onPay,
                        icon: Icons.payment,
                        height: 36,
                        gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                      ),
                    ),
                  if (isPending && widget.onPay == null)
                    Expanded(
                      child: AdminGradientButton(
                        text: 'Marquer comme payée',
                        onPressed: () => _markAsPaid(invoice),
                        icon: Icons.payment,
                        height: 36,
                        gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (widget.onPrint != null)
                    Expanded(
                      child: AdminGradientButton(
                        text: 'Imprimer',
                        onPressed: widget.onPrint,
                        icon: Icons.print,
                        height: 36,
                        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _markAsPaid(InvoiceModel invoice) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Marquer comme payée',
      message: 'Confirmez-vous que la facture #${invoice.number} a été payée ?',
      confirmText: 'Payée',
      confirmColor: Colors.green,
    );

    if (confirm == true) {
      final success = await ref.read(adminBillingProvider.notifier).markAsPaid(invoice.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facture marquée comme payée'), backgroundColor: Colors.green),
        );
      }
    }
  }
}
