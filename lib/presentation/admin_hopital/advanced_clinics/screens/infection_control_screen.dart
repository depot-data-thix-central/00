// 📁 lib/presentation/admin_hopital/advanced_clinics/screens/infection_control_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/infection_surveillance_chart.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_data_table.dart';
import '../../common/widgets/admin_empty_state.dart';

class InfectionControlScreen extends ConsumerStatefulWidget {
  const InfectionControlScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InfectionControlScreen> createState() => _InfectionControlScreenState();
}

class _InfectionControlScreenState extends ConsumerState<InfectionControlScreen> {
  bool _isLoading = false;
  String _selectedService = 'all';
  final List<String> _services = ['all', 'Cardiologie', 'Pédiatrie', 'Orthopédie', 'Urgences', 'Réanimation'];

  final List<Map<String, dynamic>> _infectionReports = [
    {'patient': 'Michel Dupont', 'type': 'Infections urinaires', 'date': '18/12/2024', 'status': 'active', 'service': 'Urgences'},
    {'patient': 'Sophie Martin', 'type': 'Pneumonie', 'date': '17/12/2024', 'status': 'resolved', 'service': 'Réanimation'},
    {'patient': 'Lucas Bernard', 'type': 'Infections du site opératoire', 'date': '16/12/2024', 'status': 'active', 'service': 'Orthopédie'},
    {'patient': 'Julie Petit', 'type': 'Bactériémie', 'date': '15/12/2024', 'status': 'resolved', 'service': 'Cardiologie'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedService == 'all'
        ? _infectionReports
        : _infectionReports.where((r) => r['service'] == _selectedService).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surveillance des infections'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des données...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Filtre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonFormField<String>(
                  value: _selectedService,
                  items: _services.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s == 'all' ? 'Tous les services' : s, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedService = v ?? _selectedService),
                  decoration: InputDecoration(
                    labelText: 'Service',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Graphique
              InfectionSurveillanceChart(service: _selectedService == 'all' ? null : _selectedService),
              const SizedBox(height: 16),
              // Liste des cas
              const Text(
                'Cas d\'infections',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                const AdminEmptyState(
                  title: 'Aucun cas',
                  subtitle: 'Aucune infection signalée dans ce service',
                  icon: Icons.medical_services_outlined,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final report = filtered[index];
                    final isActive = report['status'] == 'active';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive ? Colors.red.shade200 : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isActive ? Icons.warning_amber : Icons.check_circle,
                              size: 18,
                              color: isActive ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report['patient'],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${report['type']} • Service: ${report['service']}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  report['date'],
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isActive ? 'Actif' : 'Résolu',
                              style: TextStyle(
                                fontSize: 11,
                                color: isActive ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
