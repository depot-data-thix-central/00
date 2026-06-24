// 📁 lib/presentation/admin_hopital/advanced_finance/screens/tender_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/tender_comparator.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class TenderScreen extends ConsumerStatefulWidget {
  const TenderScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends ConsumerState<TenderScreen> {
  bool _isLoading = true;
  String _selectedOfferId = '';

  // Données mockées
  final List<Map<String, dynamic>> _offers = [
    {'id': '1', 'supplier': 'MedTech France', 'category': 'Équipement médical', 'price': 45000.0, 'delivery': '15 jours', 'score': 8.5},
    {'id': '2', 'supplier': 'Health Solutions', 'category': 'Équipement médical', 'price': 42000.0, 'delivery': '20 jours', 'score': 7.2},
    {'id': '3', 'supplier': 'Medical Plus', 'category': 'Équipement médical', 'price': 48000.0, 'delivery': '10 jours', 'score': 9.0},
    {'id': '4', 'supplier': 'Care Technology', 'category': 'Informatique', 'price': 35000.0, 'delivery': '30 jours', 'score': 6.8},
    {'id': '5', 'supplier': 'Data Health', 'category': 'Informatique', 'price': 38000.0, 'delivery': '25 jours', 'score': 7.5},
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

  void _onSelectOffer(String offerId) {
    setState(() => _selectedOfferId = offerId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offre sélectionnée: ${_offers.firstWhere((o) => o['id'] == offerId)['supplier']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createTender() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nouvel appel d\'offres créé'), backgroundColor: Colors.blue),
    );
    // Naviguer vers le formulaire
    // context.push('/admin/finance/tender/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appels d\'offres'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createTender,
            tooltip: 'Créer un appel d\'offres',
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
        message: 'Chargement des offres...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Statut de sélection
              if (_selectedOfferId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Offre sélectionnée',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              _offers.firstWhere((o) => o['id'] == _selectedOfferId)['supplier'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AdminGradientButton(
                        text: 'Confirmer',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Offre confirmée'), backgroundColor: Colors.green),
                          );
                        },
                        height: 34,
                        width: 100,
                        gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Comparateur
              TenderComparator(
                offers: _offers,
                onSelectOffer: _onSelectOffer,
              ),
              const SizedBox(height: 16),

              // Historique
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
                      'Appels d\'offres récents',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const ListTile(
                      leading: Icon(Icons.assignment, color: Colors.blue),
                      title: Text('Équipement IRM', style: TextStyle(fontSize: 13)),
                      subtitle: Text('Statut: En cours', style: TextStyle(fontSize: 11)),
                      trailing: Text('12/12/2024', style: TextStyle(fontSize: 11)),
                    ),
                    const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Scanner CT', style: TextStyle(fontSize: 13)),
                      subtitle: Text('Statut: Attribué', style: TextStyle(fontSize: 11)),
                      trailing: Text('10/12/2024', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
