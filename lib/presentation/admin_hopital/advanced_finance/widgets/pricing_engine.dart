// 📁 lib/presentation/admin_hopital/advanced_finance/widgets/pricing_engine.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/admin_search_bar.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class PricingEngine extends ConsumerStatefulWidget {
  final Function(List<Map<String, dynamic>>) onApplyPricing;
  final String patientId;
  final String patientName;

  const PricingEngine({
    Key? key,
    required this.onApplyPricing,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  ConsumerState<PricingEngine> createState() => _PricingEngineState();
}

class _PricingEngineState extends ConsumerState<PricingEngine> {
  final List<Map<String, dynamic>> _selectedActs = [];
  String _searchQuery = '';
  String _selectedTariff = 'NGAP';
  double _totalAmount = 0.0;

  final List<Map<String, dynamic>> _availableActs = [
    {'code': 'NGAP-001', 'label': 'Consultation spécialiste', 'basePrice': 60.0, 'category': 'Consultation'},
    {'code': 'NGAP-002', 'label': 'Échographie cardiaque', 'basePrice': 120.0, 'category': 'Imagerie'},
    {'code': 'T2A-001', 'label': 'Scanner IRM', 'basePrice': 350.0, 'category': 'Imagerie'},
    {'code': 'NGAP-003', 'label': 'Bilan sanguin complet', 'basePrice': 45.0, 'category': 'Biologie'},
    {'code': 'T2A-002', 'label': 'Chirurgie cardiaque', 'basePrice': 2800.0, 'category': 'Chirurgie'},
    {'code': 'NGAP-004', 'label': 'Radiographie thoracique', 'basePrice': 55.0, 'category': 'Imagerie'},
    {'code': 'T2A-003', 'label': 'Endoscopie digestive', 'basePrice': 450.0, 'category': 'Endoscopie'},
  ];

  final List<String> _tariffTypes = ['NGAP', 'T2A', 'Conventionné'];

  List<Map<String, dynamic>> get _filteredActs {
    if (_searchQuery.isEmpty) return _availableActs;
    final query = _searchQuery.toLowerCase();
    return _availableActs.where((a) =>
      a['label'].toLowerCase().contains(query) ||
      a['code'].toLowerCase().contains(query) ||
      a['category'].toLowerCase().contains(query)
    ).toList();
  }

  void _addAct(Map<String, dynamic> act) {
    setState(() {
      final existing = _selectedActs.firstWhere(
        (a) => a['code'] == act['code'],
        orElse: () => null,
      );
      if (existing != null) {
        existing['quantity'] = (existing['quantity'] ?? 1) + 1;
      } else {
        _selectedActs.add({
          ...act,
          'quantity': 1,
        });
      }
      _updateTotal();
    });
  }

  void _removeAct(int index) {
    setState(() {
      _selectedActs.removeAt(index);
      _updateTotal();
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _selectedActs.removeAt(index);
      } else {
        _selectedActs[index]['quantity'] = newQuantity;
      }
      _updateTotal();
    });
  }

  void _updateTotal() {
    _totalAmount = _selectedActs.fold(0.0, (sum, act) {
      return sum + (act['basePrice'] as double) * (act['quantity'] ?? 1);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.calculate, size: 20, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Moteur de tarification',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.patientName,
                  style: TextStyle(fontSize: 11, color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filtre de tarif
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedTariff,
                    items: _tariffTypes.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedTariff = v ?? _selectedTariff),
                    decoration: InputDecoration(
                      labelText: 'Type de tarif',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AdminSearchBar(
                  onSearch: (query) => setState(() => _searchQuery = query),
                  hintText: 'Rechercher un acte...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste des actes disponibles
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _filteredActs.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Aucun acte trouvé',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredActs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final act = _filteredActs[index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            act['code'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          act['label'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          act['category'],
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${act['basePrice'].toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AdminGradientButton(
                              text: 'Ajouter',
                              onPressed: () => _addAct(act),
                              height: 28,
                              width: 70,
                              gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          // Panier de sélection
          if (_selectedActs.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 4),
            const Text(
              'Actes sélectionnés',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._selectedActs.asMap().entries.map((entry) {
              final index = entry.key;
              final act = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        act['label'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: () => _updateQuantity(index, (act['quantity'] ?? 1) - 1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          '${act['quantity']}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () => _updateQuantity(index, (act['quantity'] ?? 1) + 1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(act['basePrice'] * (act['quantity'] ?? 1)).toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: () => _removeAct(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${_totalAmount.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AdminGradientButton(
              text: 'Appliquer la facturation',
              onPressed: () {
                widget.onApplyPricing(_selectedActs);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facturation appliquée'), backgroundColor: Colors.green),
                );
              },
              icon: Icons.check_circle,
              gradient: const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
            ),
          ],
        ],
      ),
    );
  }
}
