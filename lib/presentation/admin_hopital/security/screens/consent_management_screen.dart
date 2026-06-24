// 📁 lib/presentation/admin_hopital/security/screens/consent_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/consent_form.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';

class ConsentManagementScreen extends ConsumerStatefulWidget {
  const ConsentManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsentManagementScreen> createState() => _ConsentManagementScreenState();
}

class _ConsentManagementScreenState extends ConsumerState<ConsentManagementScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all';

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _consents = [
    {
      'id': '1',
      'patientName': 'Michel Dupont',
      'type': 'Médical',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'active',
      'duration': '1 an',
      'isDataProcessingAccepted': true,
      'isDataSharingAccepted': true,
      'isThirdPartyAccepted': false,
    },
    {
      'id': '2',
      'patientName': 'Sophie Martin',
      'type': 'Recherche',
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'status': 'active',
      'duration': '2 ans',
      'isDataProcessingAccepted': true,
      'isDataSharingAccepted': true,
      'isThirdPartyAccepted': true,
    },
    {
      'id': '3',
      'patientName': 'Lucas Bernard',
      'type': 'Médical',
      'date': DateTime.now().subtract(const Duration(days: 60)),
      'status': 'expired',
      'duration': '1 an',
      'isDataProcessingAccepted': true,
      'isDataSharingAccepted': false,
      'isThirdPartyAccepted': false,
    },
    {
      'id': '4',
      'patientName': 'Julie Petit',
      'type': 'Traitement de données',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'pending',
      'duration': '5 ans',
      'isDataProcessingAccepted': false,
      'isDataSharingAccepted': false,
      'isThirdPartyAccepted': false,
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

  List<Map<String, dynamic>> get _filteredConsents {
    var filtered = _consents;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((c) =>
        c['patientName'].toLowerCase().contains(query) ||
        c['type'].toLowerCase().contains(query)
      ).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((c) => c['status'] == _filterStatus).toList();
    }
    return filtered;
  }

  void _showAddConsentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 500,
          child: ConsentForm(
            patientName: 'Nouveau patient',
            consentType: 'Médical',
            onSave: (data) {
              Navigator.pop(context);
              setState(() {
                _consents.add({
                  'id': '${DateTime.now().millisecondsSinceEpoch}',
                  ...data,
                  'date': DateTime.now(),
                  'status': 'active',
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consentement enregistré'), backgroundColor: Colors.green),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConsents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des consentements'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddConsentDialog,
            tooltip: 'Nouveau consentement',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des consentements...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      onSearch: (query) => setState(() => _searchQuery = query),
                      hintText: 'Rechercher un patient...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'active', child: Text('Actifs', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'pending', child: Text('En attente', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'expired', child: Text('Expirés', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'revoked', child: Text('Révoqués', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                      underline: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucun consentement',
                      subtitle: 'Ajoutez un consentement patient',
                      icon: Icons.assignment_outlined,
                      actionText: 'Ajouter un consentement',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final isActive = c['status'] == 'active';
                        final isPending = c['status'] == 'pending';
                        final isExpired = c['status'] == 'expired';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive
                                  ? Colors.green.shade200
                                  : (isPending ? Colors.orange.shade200 : Colors.red.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.shade50
                                      : (isPending ? Colors.orange.shade50 : Colors.red.shade50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isActive ? Icons.check_circle : (isPending ? Icons.pending : Icons.warning),
                                  size: 22,
                                  color: isActive ? Colors.green : (isPending ? Colors.orange : Colors.red),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['patientName'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Type: ${c['type']} • Durée: ${c['duration']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Date: ${c['date'].day}/${c['date'].month}/${c['date'].year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AdminStatusBadge(
                                    status: isActive
                                        ? StatusType.completed
                                        : (isPending ? StatusType.pending : StatusType.cancelled),
                                    customLabel: isActive
                                        ? 'Actif'
                                        : (isPending ? 'En attente' : (isExpired ? 'Expiré' : 'Révoqué')),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${c['isDataProcessingAccepted'] ? '✅ ' : '❌ '}Traitement',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
