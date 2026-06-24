// 📁 lib/presentation/admin_hopital/beds/widgets/bed_occupancy_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_bed_provider.dart';

class BedOccupancyChart extends ConsumerStatefulWidget {
  final String? service;

  const BedOccupancyChart({Key? key, this.service}) : super(key: key);

  @override
  ConsumerState<BedOccupancyChart> createState() => _BedOccupancyChartState();
}

class _BedOccupancyChartState extends ConsumerState<BedOccupancyChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminBedProvider.notifier).loadBeds(service: widget.service);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminBedProvider);

    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final beds = state.beds;
    if (beds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Center(
          child: Text(
            'Aucun lit disponible',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    final total = beds.length;
    final occupied = beds.where((b) => b.status == 'occupied').length;
    final available = beds.where((b) => b.status == 'available').length;
    final cleaning = beds.where((b) => b.status == 'cleaning').length;
    final reserved = beds.where((b) => b.status == 'reserved').length;

    final occupancyRate = total > 0 ? (occupied / total * 100) : 0;

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
              const Icon(Icons.bed, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Occupation des lits',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${occupancyRate.toStringAsFixed(0)}% occupé',
                style: TextStyle(
                  fontSize: 13,
                  color: occupancyRate > 80 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de progression
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (occupied > 0)
                  Expanded(
                    flex: occupied,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(occupancyRate < 100 ? 6 : 0),
                          bottomLeft: Radius.circular(occupancyRate < 100 ? 6 : 0),
                        ),
                      ),
                    ),
                  ),
                if (cleaning > 0)
                  Expanded(
                    flex: cleaning,
                    child: Container(
                      color: Colors.orange.shade400,
                    ),
                  ),
                if (reserved > 0)
                  Expanded(
                    flex: reserved,
                    child: Container(
                      color: Colors.blue.shade400,
                    ),
                  ),
                if (available > 0)
                  Expanded(
                    flex: available,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(occupancyRate > 0 ? 0 : 6),
                          bottomRight: Radius.circular(occupancyRate > 0 ? 0 : 6),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Légende
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.red.shade500, 'Occupé ($occupied)'),
              _buildLegendItem(Colors.orange.shade400, 'Nettoyage ($cleaning)'),
              _buildLegendItem(Colors.blue.shade400, 'Réservé ($reserved)'),
              _buildLegendItem(Colors.green.shade400, 'Disponible ($available)'),
            ],
          ),
          const SizedBox(height: 12),
          // Statistiques par service (si on a plusieurs services)
          if (widget.service == null)
            _buildServiceStats(beds),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildServiceStats(List<BedModel> beds) {
    final services = <String, Map<String, int>>{};
    for (var bed in beds) {
      final service = bed.service ?? 'Autre';
      services.putIfAbsent(service, () => {'total': 0, 'occupied': 0, 'available': 0});
      services[service]!['total'] = (services[service]!['total'] ?? 0) + 1;
      if (bed.status == 'occupied') {
        services[service]!['occupied'] = (services[service]!['occupied'] ?? 0) + 1;
      } else if (bed.status == 'available') {
        services[service]!['available'] = (services[service]!['available'] ?? 0) + 1;
      }
    }

    return Column(
      children: services.entries.map((entry) {
        final service = entry.key;
        final stats = entry.value;
        final total = stats['total'] ?? 0;
        final occupied = stats['occupied'] ?? 0;
        final available = stats['available'] ?? 0;
        final rate = total > 0 ? (occupied / total * 100) : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  service,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: rate / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: rate > 80 ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${rate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: rate > 80 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
