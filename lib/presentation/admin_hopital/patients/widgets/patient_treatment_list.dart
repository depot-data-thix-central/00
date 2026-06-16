// 📁 lib/presentation/admin_hopital/patients/widgets/patient_treatment_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_medication_provider.dart';
import '../../../common/widgets/admin_status_badge.dart';
import '../../../common/widgets/admin_empty_state.dart';
import '../../../../data/models/hospital/medication_model.dart';

class PatientTreatmentList extends ConsumerStatefulWidget {
  final String patientId;

  const PatientTreatmentList({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<PatientTreatmentList> createState() => _PatientTreatmentListState();
}

class _PatientTreatmentListState extends ConsumerState<PatientTreatmentList> {
  List<MedicationModel> _treatments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() => _isLoading = true);
    try {
      // Dans la vraie vie, on filtrerait par patientId
      // Ici on récupère tous les médicaments (à adapter)
      final allMeds = await ref.read(adminMedicationProvider.notifier).loadMedications();
      // Filtrage simulé (à remplacer par un vrai appel avec patientId)
      // En attendant, on utilise des données mockées pour la démonstration
      // Ceci doit être remplacé par un appel réel au repository
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _treatments = [
            MedicationModel(
              id: '1',
              name: 'Amoxicilline',
              dosage: '500mg',
              frequency: '2x/jour',
              startDate: DateTime(2024, 1, 15),
              endDate: DateTime(2024, 1, 28),
              status: 'active',
              patientId: widget.patientId,
              prescriptionId: 'P001',
            ),
            MedicationModel(
              id: '2',
              name: 'Paracétamol',
              dosage: '1000mg',
              frequency: 'Si besoin',
              startDate: DateTime(2024, 1, 10),
              endDate: null,
              status: 'active',
              patientId: widget.patientId,
              prescriptionId: 'P002',
            ),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _treatments = [];
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

    if (_treatments.isEmpty) {
      return const AdminEmptyState(
        title: 'Aucun traitement',
        subtitle: 'Aucun traitement en cours pour ce patient',
        icon: Icons.medication_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Traitements en cours',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._treatments.map((treatment) => _TreatmentCard(treatment: treatment)),
      ],
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final MedicationModel treatment;

  const _TreatmentCard({required this.treatment});

  @override
  Widget build(BuildContext context) {
    final isActive = treatment.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.medication : Icons.medication_outlined,
              size: 22,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treatment.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${treatment.dosage} • ${treatment.frequency}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Prescrit le ${treatment.startDate.day}/${treatment.startDate.month}/${treatment.startDate.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (treatment.endDate != null)
                  Text(
                    'Jusqu\'au ${treatment.endDate!.day}/${treatment.endDate!.month}/${treatment.endDate!.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          AdminStatusBadge(
            status: isActive ? StatusType.active : StatusType.inactive,
          ),
        ],
      ),
    );
  }
}
