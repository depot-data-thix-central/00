// 📁 lib/presentation/admin_hopital/analytics/widgets/epidemic_risk_map.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class EpidemicRiskMap extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> regions;
  final DateTime lastUpdated;

  const EpidemicRiskMap({
    Key? key,
    required this.regions,
    required this.lastUpdated,
  }) : super(key: key);

  @override
  ConsumerState<EpidemicRiskMap> createState() => _EpidemicRiskMapState();
}

class _EpidemicRiskMapState extends ConsumerState<EpidemicRiskMap> {
  String _selectedRisk = 'all';
  bool _showHeatmap = true;

  List<Map<String, dynamic>> get _filteredRegions {
    if (_selectedRisk == 'all') return widget.regions;
    return widget.regions.where((r) => r['risk'] == _selectedRisk).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRegions;
    final highRiskCount = widget.regions.where((r) => r['risk'] == 'high').length;
    final mediumRiskCount = widget.regions.where((r) => r['risk'] == 'medium').length;

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
              const Icon(Icons.warning, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Risques épidémiques',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Màj: ${widget.lastUpdated.hour}:${widget.lastUpdated.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Résumé
          Row(
            children: [
              _buildRiskSummary('Risque élevé', highRiskCount, Colors.red),
              const SizedBox(width: 12),
              _buildRiskSummary('Risque modéré', mediumRiskCount, Colors.orange),
              const SizedBox(width: 12),
              _buildRiskSummary('Risque faible', widget.regions.length - highRiskCount - mediumRiskCount, Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          // Carte simulée
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://placehold.co/600x200/blue/white?text=Carte+des+risques'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: filtered.map((region) {
                final color = region['risk'] == 'high'
                    ? Colors.red
                    : (region['risk'] == 'medium' ? Colors.orange : Colors.green);
                return Positioned(
                  left: region['x'],
                  top: region['y'],
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _showHeatmap ? color.withOpacity(0.3) : color.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Contrôles
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _selectedRisk,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous les risques', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'high', child: Text('Élevé', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'medium', child: Text('Modéré', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'low', child: Text('Faible', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _selectedRisk = v ?? 'all'),
                  underline: const SizedBox.shrink(),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildLegend('Élevé', Colors.red),
                  const SizedBox(width: 8),
                  _buildLegend('Modéré', Colors.orange),
                  const SizedBox(width: 8),
                  _buildLegend('Faible', Colors.green),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showHeatmap ? Icons.map : Icons.heat_pump,
                  size: 18,
                ),
                onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
                tooltip: _showHeatmap ? 'Vue carte' : 'Vue heatmap',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste des zones à risque
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: filtered.map((region) {
                final color = region['risk'] == 'high'
                    ? Colors.red
                    : (region['risk'] == 'medium' ? Colors.orange : Colors.green);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          region['name'],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${region['cases']} cas',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          region['risk'] == 'high'
                              ? 'Élevé'
                              : (region['risk'] == 'medium' ? 'Modéré' : 'Faible'),
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          AdminGradientButton(
            text: 'Voir les détails régionaux',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Détails régionaux'), backgroundColor: Colors.blue),
              );
            },
            icon: Icons.arrow_forward,
            height: 38,
            gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSummary(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
