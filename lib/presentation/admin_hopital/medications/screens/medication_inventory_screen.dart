// 📁 lib/presentation/admin_hopital/medications/screens/medication_inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/medication_inventory_item.dart';
import '../widgets/medication_stock_alert.dart';
import '../../common/providers/admin_medication_provider.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/medication_model.dart';

class MedicationInventoryScreen extends ConsumerStatefulWidget {
  const MedicationInventoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationInventoryScreen> createState() => _MedicationInventoryScreenState();
}

class _MedicationInventoryScreenState extends ConsumerState<MedicationInventoryScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, critical, low, normal

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminMedicationProvider.notifier).loadMedications();
    });
  }

  List<MedicationModel> get _filteredMedications {
    final state = ref.watch(adminMedicationProvider);
    var filtered = state.medications;

    // Recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) =>
        m.name.toLowerCase().contains(query) ||
        m.dosage.toLowerCase().contains(query) ||
        (m.batchNumber?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filtre par statut de stock
    if (_filterStatus != 'all') {
      filtered = filtered.where((m) {
        final threshold = m.threshold ?? 30;
        final isCritical = m.quantity <= threshold * 0.5;
        final isLow = m.quantity <= threshold && !isCritical;
        if (_filterStatus == 'critical') return isCritical;
        if (_filterStatus == 'low') return isLow;
        if (_filterStatus == 'normal') return !isLow && !isCritical;
        return true;
      }).toList();
    }

    return filtered;
  }

  List<MedicationModel> get _criticalMedications {
    final state = ref.watch(adminMedicationProvider);
    return state.medications.where((m) {
      final threshold = m.threshold ?? 30;
      return m.quantity <= threshold * 0.5;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMedicationProvider);
    final notifier = ref.read(adminMedicationProvider.notifier);
    final filtered = _filteredMedications;
    final critical = _criticalMedications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaire des médicaments'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMedicationDialog(),
            tooltip: 'Ajouter un médicament',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadMedications(),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: state.isLoading && state.medications.isEmpty,
        message: 'Chargement de l\'inventaire...',
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
                          hintText: 'Rechercher un médicament...',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<String>(
                          value: _filterStatus,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'critical', child: Text('Critique', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'low', child: Text('Bas', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'normal', child: Text('Normal', style: TextStyle(fontSize: 13))),
                          ],
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
                        '${filtered.length} médicament${filtered.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (critical.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            '${critical.length} stock critique',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      AdminGradientButton(
                        text: 'Ajouter',
                        onPressed: () => _showAddMedicationDialog(),
                        icon: Icons.add,
                        height: 36,
                        width: 100,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Alertes de stock critique
            if (critical.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Alertes stock critique',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...critical.take(3).map((med) => MedicationStockAlert(
                      medication: med,
                      onDismiss: () {
                        // Optionnel : marquer comme vu
                      },
                    )),
                    if (critical.length > 3)
                      TextButton(
                        onPressed: () => setState(() => _filterStatus = 'critical'),
                        child: Text(
                          'Voir les ${critical.length} alertes',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

            // Liste des médicaments
            Expanded(
              child: filtered.isEmpty && !state.isLoading
                  ? const AdminEmptyState(
                      title: 'Aucun médicament',
                      subtitle: 'Ajoutez votre premier médicament à l\'inventaire',
                      icon: Icons.medication_outlined,
                      actionText: 'Ajouter un médicament',
                      onAction: null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final med = filtered[index];
                        return MedicationInventoryItem(
                          medication: med,
                          onTap: () {
                            // Naviguer vers le détail (à implémenter)
                          },
                          onEdit: () => _showEditMedicationDialog(med),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final formCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final thresholdCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final batchCtrl = TextEditingController();
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter un médicament'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                  hintText: '500mg',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: formCtrl,
                decoration: const InputDecoration(
                  labelText: 'Forme',
                  hintText: 'Comprimé, Gélule, etc.',
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
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: thresholdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Seuil d\'alerte',
                        hintText: '30',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix unitaire (€)',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: batchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lot',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Date d\'expiration'),
                subtitle: Text(
                  expiryDate != null
                      ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => expiryDate = picked);
                  }
                },
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
              if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty || quantityCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir les champs obligatoires'), backgroundColor: Colors.orange),
                );
                return;
              }
              final med = MedicationModel(
                id: '',
                name: nameCtrl.text,
                dosage: dosageCtrl.text,
                form: formCtrl.text.isNotEmpty ? formCtrl.text : null,
                quantity: int.tryParse(quantityCtrl.text) ?? 0,
                threshold: int.tryParse(thresholdCtrl.text) ?? 30,
                price: double.tryParse(priceCtrl.text),
                batchNumber: batchCtrl.text.isNotEmpty ? batchCtrl.text : null,
                expiryDate: expiryDate,
                status: 'active',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context);
              final success = await ref.read(adminMedicationProvider.notifier).addMedication(med);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Médicament ajouté'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicationDialog(MedicationModel med) {
    final nameCtrl = TextEditingController(text: med.name);
    final dosageCtrl = TextEditingController(text: med.dosage);
    final formCtrl = TextEditingController(text: med.form ?? '');
    final quantityCtrl = TextEditingController(text: med.quantity.toString());
    final thresholdCtrl = TextEditingController(text: med.threshold?.toString() ?? '30');
    final priceCtrl = TextEditingController(text: med.price?.toString() ?? '');
    final batchCtrl = TextEditingController(text: med.batchNumber ?? '');
    DateTime? expiryDate = med.expiryDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Modifier ${med.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: formCtrl,
                decoration: const InputDecoration(
                  labelText: 'Forme',
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
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: thresholdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Seuil d\'alerte',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix unitaire (€)',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: batchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lot',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Date d\'expiration'),
                subtitle: Text(
                  expiryDate != null
                      ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => expiryDate = picked);
                  }
                },
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
              if (nameCtrl.text.isEmpty || dosageCtrl.text.isEmpty || quantityCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir les champs obligatoires'), backgroundColor: Colors.orange),
                );
                return;
              }
              final updatedMed = med.copyWith(
                name: nameCtrl.text,
                dosage: dosageCtrl.text,
                form: formCtrl.text.isNotEmpty ? formCtrl.text : null,
                quantity: int.tryParse(quantityCtrl.text) ?? 0,
                threshold: int.tryParse(thresholdCtrl.text) ?? 30,
                price: double.tryParse(priceCtrl.text),
                batchNumber: batchCtrl.text.isNotEmpty ? batchCtrl.text : null,
                expiryDate: expiryDate,
              );
              Navigator.pop(context);
              final success = await ref.read(adminMedicationProvider.notifier).updateMedication(updatedMed);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Médicament modifié'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
