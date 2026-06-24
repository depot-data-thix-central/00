// 📁 lib/presentation/admin_hopital/analytics/screens/cdss_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cdss_alert_card.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_gradient_button.dart';

class CdssScreen extends ConsumerStatefulWidget {
  const CdssScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CdssScreen> createState() => _CdssScreenState();
}

class _CdssScreenState extends ConsumerState<CdssScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterSeverity = 'all';

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'patientName': 'Michel Dupont',
      'patientId': 'P001',
      'alertType': 'Risque de diabète',
      'description': 'Glycémie à jeun élevée (1.26 g/L) sur les 3 derniers contrôles. Facteurs de risque: obésité, antécédents familiaux.',
      'severity': CDSSSeverity.high,
      'recommendation': 'Réaliser un test d\'hyperglycémie provoquée (HGPO) et consulter un endocrinologue.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'patientName': 'Sophie Martin',
      'patientId': 'P002',
      'alertType': 'Interaction médicamenteuse',
      'description': 'Association d\'AINS et d\'anticoagulants chez une patiente âgée. Risque hémorragique élevé.',
      'severity': CDSSSeverity.critical,
      'recommendation': 'Interrompre l\'AINS immédiatement. Surveillance de l\'INR et des signes de saignement.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '3',
      'patientName': 'Lucas Bernard',
      'patientId': 'P003',
      'alertType': 'Allergie connue',
      'description': 'Patient allergique à la pénicilline. Une prescription de ce médicament a été détectée.',
      'severity': CDSSSeverity.medium,
      'recommendation': 'Modifier la prescription pour un antibiotique alternatif (macrolide).',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '4',
      'patientName': 'Julie Petit',
      'patientId': 'P004',
      'alertType': 'Signe de défaillance cardiaque',
      'description': 'Dyspnée, œdèmes des membres inférieurs. Poids en augmentation de 3 kg en 5 jours.',
      'severity': CDSSSeverity.high,
      'recommendation': 'Échocardiographie urgente, diurétiques. Suivi quotidien du poids.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simuler un appel API
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    var filtered = _alerts;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((a) =>
        a['patientName'].toLowerCase().contains(query) ||
        a['alertType'].toLowerCase().contains(query) ||
        a['description'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterSeverity != 'all') {
      filtered = filtered.where((a) => a['severity'].toString() == _filterSeverity).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAlerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide à la décision clinique'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des alertes...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      onSearch: (query) => setState(() => _searchQuery = query),
                      hintText: 'Rechercher un patient, alerte...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterSeverity,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Toutes', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'low', child: Text('Info', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'medium', child: Text('Alerte', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'high', child: Text('Urgent', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'critical', child: Text('Critique', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _filterSeverity = v ?? 'all'),
                      underline: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucune alerte',
                      subtitle: 'Aucune alerte clinique à afficher',
                      icon: Icons.health_and_safety_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final a = filtered[index];
                        return CDSSAlertCard(
                          patientName: a['patientName'],
                          patientId: a['patientId'],
                          alertType: a['alertType'],
                          description: a['description'],
                          severity: a['severity'],
                          recommendation: a['recommendation'],
                          timestamp: a['timestamp'],
                          onViewDetails: () {
                            context.push('/admin/analytics/cdss/${a['id']}');
                          },
                          onDismiss: () {
                            setState(() {
                              // Retirer l'alerte de la liste (local)
                              // Dans la vraie vie, appeler le provider pour marquer comme lu
                              _alerts.removeWhere((item) => item['id'] == a['id']);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Alerte marquée comme lue'), backgroundColor: Colors.green),
                            );
                          },
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
