// 📁 lib/presentation/admin_hopital/patients/screens/patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_data_table.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPatientProvider.notifier).loadPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminPatientProvider);
    final notifier = ref.read(adminPatientProvider.notifier);

    return AdminLoadingOverlay(
      isLoading: state.isLoading && state.patients.isEmpty,
      message: 'Chargement des patients...',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          AdminSearchBar(
            onSearch: (query) => notifier.searchPatients(query),
            hintText: 'Rechercher un patient (nom, ID, téléphone...)',
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              AdminGradientButton(
                text: 'Ajouter un patient',
                onPressed: () {
                  context.push('/admin/patients/admission');
                },
                icon: Icons.person_add,
                height: 40,
                width: 160,
              ),
              const Spacer(),
              Text(
                '${state.filteredPatients.length} patient${state.filteredPatients.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tableau
          Expanded(
            child: state.filteredPatients.isEmpty && !state.isLoading
                ? const AdminEmptyState(
                    title: 'Aucun patient trouvé',
                    subtitle: 'Ajoutez votre premier patient ou modifiez votre recherche',
                    icon: Icons.people_outline,
                    actionText: 'Ajouter un patient',
                    onAction: null, // À connecter
                  )
                : AdminDataTable(
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('ID Hôpital')),
                      DataColumn(label: Text('Téléphone')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Statut')),
                      DataColumn(label: Text('')),
                    ],
                    rows: state.filteredPatients.map((patient) {
                      return {
                        'Nom': patient.fullName,
                        'ID Hôpital': patient.hospitalId,
                        'Téléphone': patient.phoneNumber,
                        'Email': patient.email,
                        'Statut': patient.status,
                        'id': patient.id,
                      };
                    }).toList(),
                    onRowTap: (index) {
                      final patientId = state.filteredPatients[index].id;
                      context.push('/admin/patients/$patientId');
                    },
                    selectable: false,
                    isLoading: state.isLoading,
                  ),
          ),
        ],
      ),
    );
  }
}
