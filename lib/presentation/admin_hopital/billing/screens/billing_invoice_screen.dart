// 📁 lib/presentation/admin_hopital/billing/screens/billing_invoice_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/billing_invoice_item.dart';
import '../widgets/billing_summary.dart';
import '../../common/providers/admin_billing_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/invoice_model.dart';

class BillingInvoiceScreen extends ConsumerStatefulWidget {
  const BillingInvoiceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BillingInvoiceScreen> createState() => _BillingInvoiceScreenState();
}

class _BillingInvoiceScreenState extends ConsumerState<BillingInvoiceScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showSummary = true;

  final List<String> _statusFilters = [
    'all',
    'pending',
    'paid',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminBillingProvider.notifier).loadBillingData();
    });
  }

  List<InvoiceModel> get _filteredInvoices {
    final state = ref.watch(adminBillingProvider);
    var filtered = state.invoices;

    // Recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((inv) =>
        inv.number.toLowerCase().contains(query) ||
        inv.patientName.toLowerCase().contains(query) ||
        (inv.patientId?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filtre par statut
    if (_filterStatus != 'all') {
      filtered = filtered.where((inv) => inv.status == _filterStatus).toList();
    }

    // Filtre par date
    if (_startDate != null) {
      filtered = filtered.where((inv) =>
        inv.date.isAfter(_startDate!) || inv.date.isAtSameMomentAs(_startDate!)
      ).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((inv) =>
        inv.date.isBefore(_endDate!) || inv.date.isAtSameMomentAs(_endDate!)
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminBillingProvider);
    final notifier = ref.read(adminBillingProvider.notifier);
    final filtered = _filteredInvoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturation'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_showSummary ? Icons.list : Icons.summarize),
            onPressed: () => setState(() => _showSummary = !_showSummary),
            tooltip: _showSummary ? 'Vue liste' : 'Vue résumé',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateInvoiceDialog(),
            tooltip: 'Créer une facture',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: state.isLoading && state.invoices.isEmpty,
        message: 'Chargement des factures...',
        child: Column(
          children: [
            // Barre de recherche et filtres
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminSearchBar(
                          onSearch: (query) => setState(() => _searchQuery = query),
                          hintText: 'Rechercher une facture (numéro, patient)',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<String>(
                          value: _filterStatus,
                          items: _statusFilters.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s == 'all' ? 'Tous statuts' : _getStatusLabel(s),
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                          underline: const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${filtered.length} facture${filtered.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      // Filtres de date rapides
                      _buildDateFilterChip('Cette semaine', 7),
                      const SizedBox(width: 4),
                      _buildDateFilterChip('Ce mois', 30),
                      const SizedBox(width: 4),
                      _buildDateFilterChip('Tout', 0),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_month, size: 18),
                        onPressed: () => _showDatePickerDialog(),
                        tooltip: 'Sélectionner une période',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: filtered.isEmpty && !state.isLoading
                  ? const AdminEmptyState(
                      title: 'Aucune facture',
                      subtitle: 'Créez votre première facture',
                      icon: Icons.receipt_outlined,
                      actionText: 'Créer une facture',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length + (_showSummary ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (_showSummary && index == 0) {
                          return BillingSummary(
                            startDate: _startDate,
                            endDate: _endDate,
                          );
                        }
                        final invoiceIndex = _showSummary ? index - 1 : index;
                        if (invoiceIndex >= filtered.length) return const SizedBox.shrink();
                        final invoice = filtered[invoiceIndex];
                        return BillingInvoiceItem(
                          invoice: invoice,
                          onTap: () {
                            // Naviguer vers le détail
                            context.push('/admin/billing/${invoice.id}');
                          },
                          onPay: invoice.status == 'pending'
                              ? () {
                                  context.push('/admin/billing/payment/${invoice.id}');
                                }
                              : null,
                          onPrint: () {
                            // Imprimer la facture
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Impression de la facture'), backgroundColor: Colors.blue),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(String label, int days) {
    final isActive = (days == 0 && _startDate == null && _endDate == null) ||
        (days > 0 && _startDate != null &&
            DateTime.now().difference(_startDate!).inDays <= days &&
            _endDate == null);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? Colors.white : Colors.grey.shade700,
        ),
      ),
      selected: isActive,
      onSelected: (selected) {
        setState(() {
          if (days == 0) {
            _startDate = null;
            _endDate = null;
          } else {
            _startDate = DateTime.now().subtract(Duration(days: days));
            _endDate = DateTime.now();
          }
        });
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey.shade100,
    );
  }

  void _showDatePickerDialog() {
    DateTime? startDate = _startDate;
    DateTime? endDate = _endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Période de facturation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date de début'),
              subtitle: Text(
                startDate != null
                    ? '${startDate.day}/${startDate.month}/${startDate.year}'
                    : 'Non définie',
                style: TextStyle(fontSize: 13),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) startDate = picked;
                // Mise à jour du dialogue (simplifié)
              },
            ),
            ListTile(
              title: const Text('Date de fin'),
              subtitle: Text(
                endDate != null
                    ? '${endDate.day}/${endDate.month}/${endDate.year}'
                    : 'Non définie',
                style: TextStyle(fontSize: 13),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) endDate = picked;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _startDate = startDate;
                _endDate = endDate;
              });
              Navigator.pop(context);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  void _showCreateInvoiceDialog() {
    final patientCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final unitPriceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Créer une facture'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Patient *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Consultation, Examen, etc.',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantité *',
                        hintText: '1',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: unitPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix unitaire (€) *',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (patientCtrl.text.isEmpty ||
                  descriptionCtrl.text.isEmpty ||
                  quantityCtrl.text.isEmpty ||
                  unitPriceCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.orange),
                );
                return;
              }
              final quantity = int.tryParse(quantityCtrl.text) ?? 1;
              final unitPrice = double.tryParse(unitPriceCtrl.text) ?? 0;
              if (quantity <= 0 || unitPrice <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantité et prix doivent être positifs'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(context);
              // Créer la facture via le provider
              final invoice = InvoiceModel(
                id: '',
                number: 'FACT-${DateTime.now().millisecondsSinceEpoch}',
                patientId: '',
                patientName: patientCtrl.text,
                date: DateTime.now(),
                items: [
                  InvoiceItem(
                    description: descriptionCtrl.text,
                    quantity: quantity,
                    unitPrice: unitPrice,
                    total: quantity * unitPrice,
                  ),
                ],
                amount: quantity * unitPrice,
                status: 'pending',
                notes: null,
              );
              final created = await ref.read(adminBillingProvider.notifier).createInvoice(invoice);
              if (created != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facture créée'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
