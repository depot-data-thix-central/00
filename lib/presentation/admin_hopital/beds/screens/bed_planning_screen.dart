// 📁 lib/presentation/admin_hopital/beds/screens/bed_planning_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bed_occupancy_chart.dart';
import '../widgets/bed_list_tile.dart';
import '../widgets/bed_transfer_dialog.dart';
import '../../common/providers/admin_bed_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/bed_model.dart';

class BedPlanningScreen extends ConsumerStatefulWidget {
  const BedPlanningScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BedPlanningScreen> createState() => _BedPlanningScreenState();
}

class _BedPlanningScreenState extends ConsumerState<BedPlanningScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, available, occupied, cleaning, reserved

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminBedProvider.notifier).loadBeds();
    });
  }

  List<BedModel> get _filteredBeds {
    final state = ref.watch(adminBedProvider);
    var filtered = state.beds;

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((b) =>
        b.number.toLowerCase().contains(query) ||
        (b.service?.toLowerCase().contains(query) ?? false) ||
        (b.patientName?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filtrer par statut
    if (_selectedFilter != 'all') {
      filtered = filtered.where((b) => b.status == _selectedFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminBedProvider);
    final notifier = ref.read(adminBedProvider.notifier);
    final filteredBeds = _filteredBeds;

    return AdminLoadingOverlay(
      isLoading: state.isLoading && state.beds.isEmpty,
      message: 'Chargement des lits...',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche et filtres
          Row(
            children: [
              Expanded(
                child: AdminSearchBar(
                  onSearch: (query) => setState(() => _searchQuery = query),
                  hintText: 'Rechercher un lit (numéro, service, patient)',
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'available', child: Text('Disponibles', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'occupied', child: Text('Occupés', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'cleaning', child: Text('Nettoyage', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'reserved', child: Text('Réservés', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) => setState(() => _selectedFilter = v ?? 'all'),
                  underline: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Graphique d'occupation
          const BedOccupancyChart(),
          const SizedBox(height: 16),

          // Liste des lits
          Expanded(
            child: filteredBeds.isEmpty && !state.isLoading
                ? const AdminEmptyState(
                    title: 'Aucun lit trouvé',
                    subtitle: 'Aucun lit ne correspond à vos critères',
                    icon: Icons.bed_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredBeds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final bed = filteredBeds[index];
                      return BedListTile(
                        bed: bed,
                        onTap: () {
                          context.push('/admin/beds/${bed.id}');
                        },
                        onAssign: bed.status == 'available'
                            ? () => _showAssignDialog(bed)
                            : null,
                        onTransfer: bed.status == 'occupied'
                            ? () => _showTransferDialog(bed)
                            : null,
                        onClean: bed.status == 'occupied' || bed.status == 'reserved'
                            ? () => _markForCleaning(bed)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BedModel bed) {
    // Naviguer vers la liste des patients pour assigner un lit
    // On peut soit ouvrir un dialogue avec les patients, soit naviguer vers un écran d'assignation.
    // Pour simplifier, on simule une assignation avec un patient fictif.
    // Dans la vraie vie, on afficherait une liste des patients non hospitalisés.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner un patient'),
        content: const Text('Cette fonctionnalité sera bientôt disponible. Vous pourrez sélectionner un patient parmi la liste.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BedModel bed) async {
    // Récupérer le patient assigné
    final patientName = bed.patientName ?? 'Patient inconnu';
    final patientId = bed.patientId ?? '';

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun patient assigné à ce lit'), backgroundColor: Colors.orange),
      );
      return;
    }

    final result = await BedTransferDialog.show(
      context: context,
      currentBed: bed,
      patientId: patientId,
      patientName: patientName,
    );

    if (result == true) {
      // Rafraîchir la liste
      ref.read(adminBedProvider.notifier).loadBeds();
    }
  }

  void _markForCleaning(BedModel bed) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Marquer pour nettoyage',
      message: 'Le lit ${bed.number} sera marqué comme "Nettoyage". Continuer ?',
      confirmText: 'Nettoyer',
      confirmColor: Colors.orange,
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(adminBedProvider.notifier).updateBedStatus(bed.id, 'cleaning');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lit marqué pour nettoyage'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
