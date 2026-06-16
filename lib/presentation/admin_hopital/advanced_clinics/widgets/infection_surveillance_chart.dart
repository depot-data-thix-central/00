// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/infection_surveillance_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class InfectionSurveillanceChart extends ConsumerStatefulWidget {
  final String? service;

  const InfectionSurveillanceChart({Key? key, this.service}) : super(key: key);

  @override
  ConsumerState<InfectionSurveillanceChart> createState() => _InfectionSurveillanceChartState();
}

class _InfectionSurveillanceChartState extends ConsumerState<InfectionSurveillanceChart> {
  String _period = 'week';
  String _selectedInfection = 'all';

  final List<String> _periods = ['week', 'month', 'quarter'];
  final List<String> _infectionTypes = [
    'all',
    'Infections urinaires',
    'Pneumonies',
    'Infections du site opératoire',
    'Bactériémies',
    'Infections digestives',
  ];

  // Données mockées
  final Map<String, List<double>> _infectionData = {
    'Infections urinaires': [3, 4, 2, 5, 3, 6, 4],
    'Pneumonies': [2, 3, 4, 3, 5, 4, 3],
    'Infections du site opératoire': [1, 2, 1, 3, 2, 2, 1],
    'Bactériémies': [0, 1, 1, 2, 1, 3, 2],
    'Infections digestives': [2, 1, 3, 2, 1, 2, 1],
  };

  List<String> get _labels {
    if (_period == 'week') {
      return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    } else if (_period == 'month') {
      return ['S1', 'S2', 'S3', 'S4'];
    } else {
      return ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    }
  }

  List<double> get _currentData {
    if (_selectedInfection == 'all') {
      // Somme de toutes les infections
      final List<double> sums = List.filled(_labels.length, 0.0);
      for (var data in _infectionData.values) {
        for (int i = 0; i < data.length && i < sums.length; i++) {
          sums[i] += data[i];
        }
      }
      return sums;
    }
    return _infectionData[_selectedInfection] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;
    final labels = _labels;

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
              const Icon(Icons.monitor_heart, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Surveillance des infections',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _period,
                  items: _periods.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(_getPeriodLabel(p), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _period = v ?? _period),
                  underline: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButton<String>(
              value: _selectedInfection,
              items: _infectionTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type == 'all' ? 'Toutes les infections' : type,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedInfection = v ?? _selectedInfection),
              underline: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.1)),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 9),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: const TextStyle(fontSize: 9),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                minY: 0,
                maxY: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${data.reduce((a, b) => a + b)} cas',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                ),
              ),
              const Spacer(),
              if (_selectedInfection != 'all')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Moyenne: ${(data.reduce((a, b) => a + b) / data.length).toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'week':
        return 'Semaine';
      case 'month':
        return 'Mois';
      case 'quarter':
        return 'Trimestre';
      default:
        return period;
    }
  }
}
