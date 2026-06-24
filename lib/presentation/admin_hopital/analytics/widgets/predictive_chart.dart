// 📁 lib/presentation/admin_hopital/analytics/widgets/predictive_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictiveChart extends ConsumerStatefulWidget {
  final List<double> historicalData;
  final List<double> predictedData;
  final List<String> labels;
  final String title;
  final String unit;
  final Color color;

  const PredictiveChart({
    Key? key,
    required this.historicalData,
    required this.predictedData,
    required this.labels,
    required this.title,
    required this.unit,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  ConsumerState<PredictiveChart> createState() => _PredictiveChartState();
}

class _PredictiveChartState extends ConsumerState<PredictiveChart> {
  bool _showPrediction = true;

  @override
  Widget build(BuildContext context) {
    final historicalSpots = List.generate(
      widget.historicalData.length,
      (i) => FlSpot(i.toDouble(), widget.historicalData[i]),
    );

    final predictedSpots = List.generate(
      widget.predictedData.length,
      (i) => FlSpot(
        (widget.historicalData.length + i).toDouble(),
        widget.predictedData[i],
      ),
    );

    final allSpots = [...historicalSpots, ...predictedSpots];
    final minY = 0.0;
    final maxY = (allSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2);

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
              const Icon(Icons.trending_up, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _showPrediction ? 'prediction' : 'history',
                  items: const [
                    DropdownMenuItem(value: 'history', child: Text('Historique', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'prediction', child: Text('Prédiction', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _showPrediction = v == 'prediction'),
                  underline: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: historicalSpots,
                    isCurved: true,
                    color: widget.color,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: widget.color.withOpacity(0.1),
                    ),
                  ),
                  if (_showPrediction)
                    LineChartBarData(
                      spots: predictedSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      dashArray: const [8, 4],
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
                        if (index >= 0 && index < widget.labels.length) {
                          return Text(
                            widget.labels[index],
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
                minY: minY,
                maxY: maxY,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Historique', widget.color),
              if (_showPrediction) ...[
                const SizedBox(width: 16),
                _buildLegend('Prédiction', Colors.red),
              ],
              const SizedBox(width: 16),
              _buildLegend('Intervalle de confiance', Colors.grey, dashed: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, {bool dashed = false}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: dashed ? Border.all(color: color, width: 1) : null,
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
