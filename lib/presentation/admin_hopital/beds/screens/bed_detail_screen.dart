// 📁 lib/presentation/admin_hopital/beds/screens/bed_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bed_transfer_dialog.dart';
import '../../common/providers/admin_bed_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../../common/widgets/admin_confirm_dialog.dart';
import '../../../../data/models/hospital/bed_model.dart';

class BedDetailScreen extends ConsumerStatefulWidget {
  final String bedId;

  const BedDetailScreen({
    Key? key,
    required this.bedId,
  }) : super(key: key);

  @override
  ConsumerState<BedDetailScreen> createState() => _BedDetailScreenState();
}

class _BedDetailScreenState extends ConsumerState<BedDetailScreen> {
  BedModel? _bed;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBed();
  }

  Future<void> _loadBed() async {
    final state = ref.watch(adminBedProvider);
    final bed = state.beds.firstWhere(
      (b) => b.id == widget.bedId,
      orElse: () => null,
    );
    if (bed != null) {
      setState(() {
        _bed = bed;
        _isLoading = false;
      });
    } else {
      // Si pas dans la liste, on recharge
      await ref.read(adminBedProvider.notifier).loadBeds();
      final newState = ref.read(adminBedProvider);
      final found = newState.beds.firstWhere(
        (b) => b.id == widget.bedId,
        orElse: () => null,
      );
      if (found != null) {
        setState(() {
          _bed = found;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Lit non trouvé';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(_error!, style: const TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    final bed = _bed!;
    final color = _getStatusColor(bed.status);
    final statusLabel = _getStatusLabel(bed.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du lit ${bed.number}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (bed.status == 'occupied')
            IconButton(
              icon: const Icon(Icons.cleaning_services, color: Colors.orange),
              onPressed: () => _markForCleaning(bed),
              tooltip: 'Marquer pour nettoyage',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'identité du lit
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        _getStatusIcon(bed.status),
                        size: 32,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lit ${bed.number}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bed.service ?? 'Service général',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AdminStatusBadge(
                          status: _getStatusType(bed.status),
                          customLabel: statusLabel,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informations détaillées
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Numéro', bed.number),
                  _buildInfoRow('Service', bed.service ?? 'Non défini'),
                  _buildInfoRow('Statut', statusLabel),
                  if (bed.patientName != null) ...[
                    _buildInfoRow('Patient', bed.patientName!),
                    if (bed.patientId != null)
                      _buildInfoRow('ID Patient', bed.patientId!),
                  ],
                  if (bed.patientName == null || bed.status != 'occupied')
                    _buildInfoRow('Patient', 'Aucun patient assigné'),
                  if (bed.roomNumber != null)
                    _buildInfoRow('Chambre', bed.roomNumber!),
                  if (bed.ward != null)
                    _buildInfoRow('Aile', bed.ward!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            if (bed.status == 'available')
              AdminGradientButton(
                text: 'Assigner un patient',
                onPressed: () => _showAssignDialog(bed),
                icon: Icons.person_add,
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              ),

            if (bed.status == 'occupied') ...[
              AdminGradientButton(
                text: 'Transférer le patient',
                onPressed: () => _showTransferDialog(bed),
                icon: Icons.swap_horiz,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
              const SizedBox(height: 12),
              AdminGradientButton(
                text: 'Libérer le lit (nettoyage)',
                onPressed: () => _markForCleaning(bed),
                icon: Icons.cleaning_services,
                gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
              ),
            ],

            if (bed.status == 'cleaning')
              AdminGradientButton(
                text: 'Marquer comme disponible',
                onPressed: () => _markAsAvailable(bed),
                icon: Icons.check_circle,
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              ),

            if (bed.status == 'reserved')
              AdminGradientButton(
                text: 'Annuler la réservation',
                onPressed: () => _cancelReservation(bed),
                icon: Icons.cancel,
                gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BedModel bed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner un patient'),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
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
    final patientName = bed.patientName ?? 'Patient inconnu';
    final patientId = bed.patientId ?? '';

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun patient assigné'), backgroundColor: Colors.orange),
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
      await _loadBed();
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
      await _loadBed();
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

  void _markAsAvailable(BedModel bed) async {
    try {
      await ref.read(adminBedProvider.notifier).updateBedStatus(bed.id, 'available');
      await _loadBed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lit marqué comme disponible'), backgroundColor: Colors.green),
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

  void _cancelReservation(BedModel bed) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Annuler la réservation',
      message: 'Voulez-vous annuler la réservation du lit ${bed.number} ?',
      confirmText: 'Annuler',
      confirmColor: Colors.red,
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(adminBedProvider.notifier).updateBedStatus(bed.id, 'available');
      await _loadBed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green),
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

  // Helpers
  Color _getStatusColor(String status) {
    switch (status) {
      case 'occupied':
        return Colors.red;
      case 'available':
        return Colors.green;
      case 'cleaning':
        return Colors.orange;
      case 'reserved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'occupied':
        return Icons.bed;
      case 'available':
        return Icons.bed_outlined;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'reserved':
        return Icons.bookmark;
      default:
        return Icons.bed;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'occupied':
        return 'Occupé';
      case 'available':
        return 'Disponible';
      case 'cleaning':
        return 'Nettoyage';
      case 'reserved':
        return 'Réservé';
      default:
        return status;
    }
  }

  StatusType _getStatusType(String status) {
    switch (status) {
      case 'occupied':
        return StatusType.active;
      case 'available':
        return StatusType.completed;
      case 'cleaning':
        return StatusType.warning;
      case 'reserved':
        return StatusType.pending;
      default:
        return StatusType.inactive;
    }
  }
}
