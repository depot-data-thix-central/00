// 📁 lib/presentation/admin_hopital/advanced_finance/widgets/payment_reminder.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class PaymentReminder extends ConsumerStatefulWidget {
  final Function(List<String>) onSendReminders;
  final List<Map<String, dynamic>> invoices;

  const PaymentReminder({
    Key? key,
    required this.onSendReminders,
    required this.invoices,
  }) : super(key: key);

  @override
  ConsumerState<PaymentReminder> createState() => _PaymentReminderState();
}

class _PaymentReminderState extends ConsumerState<PaymentReminder> {
  final List<String> _selectedIds = [];
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final overdueInvoices = widget.invoices.where((inv) => inv['status'] == 'overdue').toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Relances de paiement',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${overdueInvoices.length} impayé${overdueInvoices.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (overdueInvoices.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 40, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'Aucun impayé à relancer',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Action bar
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _selectAll,
                      onChanged: (v) {
                        setState(() {
                          _selectAll = v ?? false;
                          if (_selectAll) {
                            _selectedIds.clear();
                            _selectedIds.addAll(overdueInvoices.map((inv) => inv['id'] as String));
                          } else {
                            _selectedIds.clear();
                          }
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tout',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Spacer(),
                AdminGradientButton(
                  text: 'Envoyer les relances (${_selectedIds.length})',
                  onPressed: _selectedIds.isNotEmpty ? () => widget.onSendReminders(_selectedIds) : null,
                  height: 34,
                  width: 180,
                  gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Liste des factures
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: overdueInvoices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final inv = overdueInvoices[index];
                  final isSelected = _selectedIds.contains(inv['id']);
                  final daysOverdue = DateTime.now().difference(inv['dueDate']).inDays;
                  final color = daysOverdue > 30 ? Colors.red : (daysOverdue > 15 ? Colors.orange : Colors.yellow.shade700);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedIds.add(inv['id']);
                              } else {
                                _selectedIds.remove(inv['id']);
                              }
                              _selectAll = _selectedIds.length == overdueInvoices.length;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Facture #${inv['number']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Patient: ${inv['patient']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(inv['amount'] as double).toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$daysOverdue jours',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
