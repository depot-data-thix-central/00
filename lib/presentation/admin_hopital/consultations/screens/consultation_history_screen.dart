// 📁 lib/presentation/admin_hopital/consultations/screens/consultation_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_status_badge.dart';

class ConsultationHistoryScreen extends ConsumerStatefulWidget {
  final String patientId;

  const ConsultationHistoryScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends ConsumerState<ConsultationHistoryScreen> {
  List<Map<String, dynamic>> _consultations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    // Simuler un chargement depuis une API
    await Future.delayed(const Duration(milliseconds: 800));
    // Données mockées pour l'exemple
    final mockConsultations = [
      {
        'id': 'C001',
        'date': DateTime(2024, 12, 18, 14, 30),
        'doctor': 'Dr. Martin',
        'specialty': 'Cardiologue',
        'motif': 'Douleur thoracique',
        'diagnostic': 'I10 - Hypertension',
        'treatment': 'Amélioration du régime alimentaire',
        'status': 'completed',
        'vitalSigns': {'temperature': '37.2', 'systolic': '135', 'diastolic': '85'},
      },
      {
        'id': 'C002',
        'date': DateTime(2024, 12, 10, 09, 00),
        'doctor': 'Dr. Bernard',
        'specialty': 'Généraliste',
        'motif': 'Toux persistante',
        'diagnostic': 'J06.9 - Infection respiratoire',
        'treatment': 'Amoxicilline 500mg 2x/jour',
        'status': 'completed',
        'vitalSigns': {'temperature': '38.1', 'heartRate': '92'},
      },
      {
        'id': 'C003',
        'date': DateTime(2024, 11, 25, 16, 15),
        'doctor': 'Dr. Petit',
        'specialty': 'Dermatologue',
        'motif': 'Éruption cutanée',
        'diagnostic': 'L30.9 - Dermatite',
        'treatment': 'Crème corticoïde',
        'status': 'completed',
        'vitalSigns': {},
      },
    ];
    setState(() {
      _consultations = mockConsultations;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredConsultations {
    if (_searchQuery.isEmpty) return _consultations;
    final query = _searchQuery.toLowerCase();
    return _consultations.where((c) =>
      c['doctor'].toLowerCase().contains(query) ||
      c['motif'].toLowerCase().contains(query) ||
      c['diagnostic'].toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(adminPatientProvider);
    final patient = patientState.patients.firstWhere(
      (p) => p.id == widget.patientId,
      orElse: () => null,
    );
    final patientName = patient?.fullName ?? 'Patient';

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des consultations - $patientName'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement de l\'historique...',
        child: Column(
          children: [
            AdminSearchBar(
              onSearch: (query) => setState(() => _searchQuery = query),
              hintText: 'Rechercher par médecin, motif...',
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredConsultations.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucune consultation',
                      subtitle: 'Ce patient n\'a pas encore d\'historique de consultations',
                      icon: Icons.history,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filteredConsultations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = _filteredConsultations[index];
                        return _ConsultationCard(consultation: c);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final Map<String, dynamic> consultation;

  const _ConsultationCard({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final date = consultation['date'] as DateTime;
    final doctor = consultation['doctor'] as String;
    final specialty = consultation['specialty'] as String?;
    final motif = consultation['motif'] as String;
    final diagnostic = consultation['diagnostic'] as String;
    final treatment = consultation['treatment'] as String?;
    final vitalSigns = consultation['vitalSigns'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_services, size: 18, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (specialty != null)
                      Text(
                        specialty,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              Text(
                '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const Divider(height: 16),
          // Détails
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Motif', motif),
                    _buildDetailRow('Diagnostic', diagnostic),
                    if (treatment != null) _buildDetailRow('Traitement', treatment),
                  ],
                ),
              ),
              if (vitalSigns != null && vitalSigns.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    vitalSigns.keys.map((k) => '${_getVitalLabel(k)}: ${vitalSigns[k]}').join(' • '),
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AdminStatusBadge(
                status: StatusType.completed,
                customLabel: 'Terminé',
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Naviguer vers le détail complet
                },
                child: const Text('Voir détail', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getVitalLabel(String key) {
    switch (key) {
      case 'temperature': return 'T';
      case 'systolic': return 'Sys';
      case 'diastolic': return 'Dia';
      case 'heartRate': return 'Pouls';
      case 'spo2': return 'SpO2';
      default: return key;
    }
  }
}
