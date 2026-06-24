// 📁 lib/presentation/admin_hopital/patients/screens/patient_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/patient_medical_history.dart';
import '../widgets/patient_treatment_list.dart';
import '../widgets/patient_document_upload.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(adminPatientProvider);
    final patient = patientState.patients.firstWhere(
      (p) => p.id == widget.patientId,
      orElse: () => null,
    );

    if (patient == null && !patientState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient non trouvé')),
        body: const Center(child: Text('Ce patient n\'existe pas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(patient?.fullName ?? 'Détail patient'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.push('/admin/patients/${widget.patientId}/edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Confirmation et suppression
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Traitements'),
            Tab(text: 'Documents'),
            Tab(text: 'Examens'),
          ],
        ),
      ),
      body: AdminLoadingOverlay(
        isLoading: patientState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Résumé
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PatientMedicalHistory(patientId: widget.patientId),
                  const SizedBox(height: 16),
                  // Statut
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Statut actuel :',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        AdminStatusBadge(
                          status: patient?.status == 'active'
                              ? StatusType.active
                              : patient?.status == 'inactive'
                                  ? StatusType.inactive
                                  : StatusType.pending,
                          customLabel: patient?.status ?? 'Inconnu',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Traitements
            PatientTreatmentList(patientId: widget.patientId),
            // Documents
            PatientDocumentUpload(patientId: widget.patientId),
            // Examens (à implémenter)
            const Center(child: Text('Historique des examens (à venir)')),
          ],
        ),
      ),
    );
  }
}
