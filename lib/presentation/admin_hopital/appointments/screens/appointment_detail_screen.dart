// 📁 lib/presentation/admin_hopital/appointments/screens/appointment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_appointment_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../widgets/appointment_card.dart';
import '../../../../data/models/hospital/appointment_model.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  ConsumerState<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends ConsumerState<AppointmentDetailScreen> {
  AppointmentModel? _appointment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    final state = ref.watch(adminAppointmentProvider);
    final appointment = state.appointments.firstWhere(
      (a) => a.id == widget.appointmentId,
      orElse: () => null,
    );
    if (appointment != null) {
      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } else {
      // Si pas dans la liste, on recharge
      await ref.read(adminAppointmentProvider.notifier).loadAppointments();
      final newState = ref.read(adminAppointmentProvider);
      final found = newState.appointments.firstWhere(
        (a) => a.id == widget.appointmentId,
        orElse: () => null,
      );
      if (found != null) {
        setState(() {
          _appointment = found;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Rendez-vous non trouvé';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du rendez-vous'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_appointment!.status != 'cancelled' && _appointment!.status != 'completed')
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: _cancelAppointment,
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale
            AppointmentCard(
              appointment: _appointment!,
              onTap: null,
              onCancel: _appointment!.status != 'cancelled' && _appointment!.status != 'completed'
                  ? _cancelAppointment
                  : null,
              onReschedule: _appointment!.status != 'cancelled' && _appointment!.status != 'completed'
                  ? () {
                      // Naviguer vers l'édition (à implémenter)
                    }
                  : null,
            ),
            const SizedBox(height: 20),

            // Informations complémentaires
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
                    'Informations détaillées',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Patient', _appointment!.patientName),
                  _buildInfoRow('Médecin', _appointment!.doctorName),
                  _buildInfoRow('Spécialité', _appointment!.specialty),
                  _buildInfoRow('Date', '${_appointment!.date.day}/${_appointment!.date.month}/${_appointment!.date.year}'),
                  _buildInfoRow('Heure', _appointment!.time),
                  _buildInfoRow('Statut', _appointment!.status),
                  if (_appointment!.notes != null) ...[
                    const Divider(),
                    const Text('Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(_appointment!.notes!, style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            if (_appointment!.status != 'cancelled' && _appointment!.status != 'completed')
              Row(
                children: [
                  Expanded(
                    child: AdminGradientButton(
                      text: 'Marquer comme effectué',
                      onPressed: _completeAppointment,
                      icon: Icons.done_all,
                      gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminGradientButton(
                      text: 'Annuler',
                      onPressed: _cancelAppointment,
                      icon: Icons.cancel,
                      gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Future<void> _cancelAppointment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(adminAppointmentProvider.notifier)
          .cancelAppointment(_appointment!.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous annulé'), backgroundColor: Colors.green),
        );
        // Recharger les données
        await ref.read(adminAppointmentProvider.notifier).loadAppointments();
        if (mounted) {
          _loadAppointment();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'annulation'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeAppointment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marquer comme effectué'),
        content: const Text('Confirmez-vous que ce rendez-vous a eu lieu ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Mise à jour du statut (à ajouter dans le provider si besoin)
      // On simule ici, mais idéalement ajouter une méthode updateAppointment
      // Pour l'exemple, on modifie directement le statut (à remplacer par un vrai appel)
      final updated = _appointment!.copyWith(status: 'completed');
      final success = await ref.read(adminAppointmentProvider.notifier)
          .updateAppointment(updated);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous marqué comme effectué'), backgroundColor: Colors.green),
        );
        if (mounted) {
          _loadAppointment();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
