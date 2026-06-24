// 📁 lib/presentation/admin_hopital/beds/widgets/bed_transfer_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_bed_provider.dart';
import '../../../common/widgets/admin_search_bar.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_empty_state.dart';
import '../../../../data/models/hospital/bed_model.dart';

class BedTransferDialog extends ConsumerStatefulWidget {
  final BedModel currentBed;
  final String patientId;
  final String patientName;

  const BedTransferDialog({
    Key? key,
    required this.currentBed,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  ConsumerState<BedTransferDialog> createState() => _BedTransferDialogState();
}

class _BedTransferDialogState extends ConsumerState<BedTransferDialog> {
  String _searchQuery = '';
  String? _selectedBedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminBedProvider.notifier).loadBeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminBedProvider);
    final availableBeds = state.beds.where((b) =>
      b.id != widget.currentBed.id &&
      (b.status == 'available' || b.status == 'cleaning')
    ).toList();

    final filteredBeds = _searchQuery.isEmpty
        ? availableBeds
        : availableBeds.where((b) =>
            b.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (b.service?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          ).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                const Icon(Icons.swap_horiz, size: 24, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Transférer le patient',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Patient: ${widget.patientName}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            Text(
              'Lit actuel: ${widget.currentBed.number}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            // Recherche
            AdminSearchBar(
              onSearch: (query) => setState(() => _searchQuery = query),
              hintText: 'Rechercher un lit disponible...',
            ),
            const SizedBox(height: 12),
            // Liste des lits
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (availableBeds.isEmpty)
              const AdminEmptyState(
                title: 'Aucun lit disponible',
                subtitle: 'Tous les lits sont occupés',
                icon: Icons.bed_outlined,
              )
            else if (filteredBeds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  itemCount: filteredBeds.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final bed = filteredBeds[index];
                    final isSelected = _selectedBedId == bed.id;
                    return InkWell(
                      onTap: () => setState(() => _selectedBedId = bed.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: bed.id,
                              groupValue: _selectedBedId,
                              onChanged: (_) => setState(() => _selectedBedId = bed.id),
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lit ${bed.number}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    bed.service ?? 'Service général',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bed.status == 'available'
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bed.status == 'available' ? 'Disponible' : 'Nettoyage',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: bed.status == 'available'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: 'Confirmer le transfert',
                    onPressed: _selectedBedId != null ? _confirmTransfer : null,
                    icon: Icons.check_circle,
                    gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Annuler', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmTransfer() async {
    if (_selectedBedId == null) return;

    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Confirmer le transfert',
      message: 'Êtes-vous sûr de vouloir transférer le patient ${widget.patientName} du lit ${widget.currentBed.number} vers le lit sélectionné ?',
      confirmText: 'Transférer',
      confirmColor: Colors.blue,
    );

    if (confirm != true || !mounted) return;

    try {
      // Mettre à jour les statuts des lits
      final bedNotifier = ref.read(adminBedProvider.notifier);

      // Libérer l'ancien lit
      await bedNotifier.updateBedStatus(widget.currentBed.id, 'cleaning');

      // Occuper le nouveau lit
      await bedNotifier.assignPatientToBed(_selectedBedId!, widget.patientId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfert effectué avec succès'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<bool?> show(BuildContext context, {
    required BedModel currentBed,
    required String patientId,
    required String patientName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BedTransferDialog(
        currentBed: currentBed,
        patientId: patientId,
        patientName: patientName,
      ),
    );
  }
}
