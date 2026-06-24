// 📁 lib/presentation/admin_hopital/advanced_finance/widgets/tender_comparator.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class TenderComparator extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> offers;
  final Function(String) onSelectOffer;

  const TenderComparator({
    Key? key,
    required this.offers,
    required this.onSelectOffer,
  }) : super(key: key);

  @override
  ConsumerState<TenderComparator> createState() => _TenderComparatorState();
}

class _TenderComparatorState extends ConsumerState<TenderComparator> {
  String _selectedCategory = 'Équipement médical';
  String _selectedOfferId = '';

  final List<String> _categories = ['Équipement médical', 'Informatique', 'Fournitures', 'Maintenance', 'Consulting'];
  final List<Color> _colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];

  @override
  Widget build(BuildContext context) {
    final offers = widget.offers.where((o) => o['category'] == _selectedCategory).toList();

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
              const Icon(Icons.compare_arrows, size: 20, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'Comparateur d\'offres',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                  underline: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (offers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune offre disponible pour cette catégorie',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                  columns: const [
                    DataColumn(label: Text('Fournisseur', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Prix (€)', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Délai', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Score', style: TextStyle(fontSize: 12))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12))),
                  ],
                  rows: offers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final offer = entry.value;
                    final isBestPrice = offer['price'] == offers.map((o) => o['price']).reduce((a, b) => a < b ? a : b);
                    final isBestScore = offer['score'] == offers.map((o) => o['score']).reduce((a, b) => a > b ? a : b);
                    final isSelected = _selectedOfferId == offer['id'];
                    return DataRow(
                      color: MaterialStateProperty.all(
                        isSelected ? Colors.indigo.shade50 : (index % 2 == 0 ? Colors.transparent : Colors.grey.shade100.withOpacity(0.3)),
                      ),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _colors[index % _colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                offer['supplier'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isBestPrice || isBestScore ? FontWeight.bold : FontWeight.normal,
                                  color: isBestPrice || isBestScore ? Colors.indigo : Colors.black87,
                                ),
                              ),
                              if (isBestPrice)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.star, size: 12, color: Colors.amber),
                                ),
                              if (isBestScore)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.thumb_up, size: 12, color: Colors.green),
                                ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(offer['price']),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isBestPrice ? FontWeight.bold : FontWeight.normal,
                              color: isBestPrice ? Colors.green : Colors.black87,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            offer['delivery'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Text(
                                offer['score'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isBestScore ? FontWeight.bold : FontWeight.normal,
                                  color: isBestScore ? Colors.green : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                height: 4,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: (offer['score'] / 10).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: offer['score'] >= 8 ? Colors.green : (offer['score'] >= 6 ? Colors.orange : Colors.red),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isSelected)
                                AdminGradientButton(
                                  text: 'Sélectionner',
                                  onPressed: () {
                                    setState(() => _selectedOfferId = offer['id']);
                                    widget.onSelectOffer(offer['id']);
                                  },
                                  height: 28,
                                  width: 80,
                                  gradient: const LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Sélectionné',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (offers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⭐ Prix le plus bas • 👍 Meilleur score • Cliquez sur "Sélectionner" pour valider une offre.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
