// lib/presentation/chat/data_saver/data_usage_stats.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataUsageStats extends StatefulWidget {
  const DataUsageStats({super.key});

  @override
  State<DataUsageStats> createState() => _DataUsageStatsState();
}

class _DataUsageStatsState extends State<DataUsageStats> {
  String _timeRange = 'month';
  Map<String, int> _usageData = {};
  bool _isLoading = true;

  final List<Map<String, String>> _timeRanges = [
    {'label': 'Aujourd\'hui', 'value': 'day'},
    {'label': 'Cette semaine', 'value': 'week'},
    {'label': 'Ce mois', 'value': 'month'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    setState(() => _isLoading = true);
    
    // Simuler des données
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _usageData = {
        'images': 245,
        'videos': 1890,
        'audio': 125,
        'documents': 340,
        'total': 2600,
      };
      _isLoading = false;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Utilisation des données',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Time range selector
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _timeRanges.map((range) {
                      final isSelected = _timeRange == range['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _timeRange = range['value']!);
                          _loadUsageData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            range['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                // Total usage card
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B1B3D), Color(0xFF1A2B4D)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Utilisation totale',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatBytes(_usageData['total'] ?? 0),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_down, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            const Text(
                              '15%',
                              style: TextStyle(fontSize: 10, color: Colors.green),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'vs période précédente',
                              style: TextStyle(fontSize: 9, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Breakdown by type
                Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Détail par type',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _buildUsageItem(Icons.image, 'Images', _usageData['images'] ?? 0, const Color(0xFF4CAF50)),
                      _buildUsageItem(Icons.videocam, 'Vidéos', _usageData['videos'] ?? 0, const Color(0xFF2196F3)),
                      _buildUsageItem(Icons.mic, 'Audio', _usageData['audio'] ?? 0, const Color(0xFFFF9800)),
                      _buildUsageItem(Icons.insert_drive_file, 'Documents', _usageData['documents'] ?? 0, const Color(0xFF9C27B0)),
                    ],
                  ),
                ),
                
                // Savings suggestion
                if (_usageData['total'] != null && _usageData['total']! > 500)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, size: 24, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Astuce économie',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Activez le mode économie de données pour réduire votre consommation jusqu\'à 75%',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LowDataModeToggle()),
                            );
                          },
                          child: const Text('Activer', style: TextStyle(fontSize: 11, color: Color(0xFFD4AF37))),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildUsageItem(IconData icon, String label, int bytes, Color color) {
    final percentage = _usageData['total']! > 0 ? (bytes / _usageData['total']! * 100) : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatBytes(bytes),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
