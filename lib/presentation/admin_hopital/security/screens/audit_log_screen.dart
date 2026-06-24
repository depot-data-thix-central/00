// 📁 lib/presentation/admin_hopital/security/screens/audit_log_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/audit_log_item.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_date_picker.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterAction = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  // Données mockées
  final List<Map<String, dynamic>> _logs = [
    {
      'id': '1',
      'action': 'Connexion',
      'user': 'Dr. Martin',
      'userRole': 'Médecin',
      'target': 'Session utilisateur',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'details': 'Connexion réussie depuis l\'IP 192.168.1.10',
      'ipAddress': '192.168.1.10',
    },
    {
      'id': '2',
      'action': 'Consultation de dossier',
      'user': 'Dr. Bernard',
      'userRole': 'Médecin',
      'target': 'Dossier de Michel Dupont',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'details': 'Consultation du dossier patient',
      'ipAddress': '192.168.1.15',
    },
    {
      'id': '3',
      'action': 'Modification de données sensibles',
      'user': 'Dr. Petit',
      'userRole': 'Médecin',
      'target': 'Prescription de Lucas Bernard',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'details': 'Modification de la posologie d\'amoxicilline',
      'ipAddress': '192.168.1.20',
    },
    {
      'id': '4',
      'action': 'Suppression de dossier',
      'user': 'Admin',
      'userRole': 'Administrateur',
      'target': 'Dossier de Julie Petit',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'details': 'Suppression de dossier suite à demande de la patiente',
      'ipAddress': '192.168.1.5',
    },
    {
      'id': '5',
      'action': 'Export de données',
      'user': 'Dr. Dubois',
      'userRole': 'Médecin',
      'target': 'Rapport d\'activité',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'details': 'Export des consultations du mois en PDF',
      'ipAddress': '192.168.1.25',
    },
    {
      'id': '6',
      'action': 'Échec de connexion',
      'user': 'Utilisateur inconnu',
      'userRole': 'Inconnu',
      'target': 'Tentative de connexion',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'details': '5 tentatives échouées depuis l\'IP 10.0.0.50',
      'ipAddress': '10.0.0.50',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredLogs {
    var filtered = _logs;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((l) =>
        l['action'].toLowerCase().contains(query) ||
        l['user'].toLowerCase().contains(query) ||
        l['target'].toLowerCase().contains(query) ||
        (l['details']?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    if (_filterAction != 'all') {
      filtered = filtered.where((l) => l['action'] == _filterAction).toList();
    }
    if (_startDate != null) {
      filtered = filtered.where((l) => l['timestamp'].isAfter(_startDate!) || l['timestamp'].isAtSameMomentAs(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((l) => l['timestamp'].isBefore(_endDate!) || l['timestamp'].isAtSameMomentAs(_endDate!)).toList();
    }
    return filtered;
  }

  List<String> get _actionOptions {
    final actions = _logs.map((l) => l['action'] as String).toSet().toList();
    return ['all', ...actions];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal d'audit"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export du journal d\'audit'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Exporter',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement du journal...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminSearchBar(
                          onSearch: (query) => setState(() => _searchQuery = query),
                          hintText: 'Rechercher dans le journal...',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<String>(
                          value: _filterAction,
                          items: _actionOptions.map((a) {
                            return DropdownMenuItem(
                              value: a,
                              child: Text(a == 'all' ? 'Toutes les actions' : a, style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _filterAction = v ?? 'all'),
                          underline: const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AdminDatePicker(
                          label: 'Date de début',
                          selectedDate: _startDate,
                          onDateSelected: (date) => setState(() => _startDate = date),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AdminDatePicker(
                          label: 'Date de fin',
                          selectedDate: _endDate,
                          onDateSelected: (date) => setState(() => _endDate = date),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AdminGradientButton(
                        text: 'Réinitialiser',
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                        height: 38,
                        width: 100,
                        gradient: const LinearGradient(colors: [Colors.grey, Colors.grey]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucune entrée',
                      subtitle: 'Aucune entrée de journal correspondant aux critères',
                      icon: Icons.history_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final l = filtered[index];
                        return AuditLogItem(
                          action: l['action'],
                          user: l['user'],
                          userRole: l['userRole'],
                          target: l['target'],
                          timestamp: l['timestamp'],
                          details: l['details'],
                          ipAddress: l['ipAddress'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
