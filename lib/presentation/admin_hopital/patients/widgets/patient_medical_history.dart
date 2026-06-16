// 📁 lib/presentation/admin_hopital/patients/widgets/patient_medical_history.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_patient_provider.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_empty_state.dart';
import '../../../../data/models/hospital/patient_model.dart';

class PatientMedicalHistory extends ConsumerStatefulWidget {
  final String patientId;

  const PatientMedicalHistory({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<PatientMedicalHistory> createState() => _PatientMedicalHistoryState();
}

class _PatientMedicalHistoryState extends ConsumerState<PatientMedicalHistory> {
  PatientModel? _patient;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final patient = await ref.read(adminPatientProvider.notifier).getPatientById(widget.patientId);
      if (mounted) {
        setState(() {
          _patient = patient;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_error != null || _patient == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _error ?? 'Patient non trouvé',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informations personnelles
        _buildPersonalInfo(),
        const SizedBox(height: 20),
        // Antécédents
        _buildAntecedents(),
        const SizedBox(height: 20),
        // Allergies
        _buildAllergies(),
      ],
    );
  }

  Widget _buildPersonalInfo() {
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
          const Text(
            'Informations personnelles',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nom complet', _patient!.fullName),
          _buildInfoRow('Date de naissance', _patient!.birthDate),
          _buildInfoRow('Genre', _patient!.gender),
          _buildInfoRow('Email', _patient!.email),
          _buildInfoRow('Téléphone', _patient!.phoneNumber),
          _buildInfoRow('Adresse', _patient!.address),
          _buildInfoRow('N° THIX ID', _patient!.hospitalId),
          _buildInfoRow('Groupe sanguin', _patient!.bloodType ?? 'Non renseigné'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildAntecedents() {
    final antecedents = _patient!.medicalHistory ?? [];

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
          const Text(
            'Antécédents médicaux',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (antecedents.isEmpty)
            const Text(
              'Aucun antécédent renseigné',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            )
          else
            Column(
              children: antecedents.map((a) => Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.medical_information, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAllergies() {
    final allergies = _patient!.allergies ?? [];

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
          const Text(
            'Allergies',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (allergies.isEmpty)
            const Text(
              'Aucune allergie connue',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergies.map((a) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  a,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}
