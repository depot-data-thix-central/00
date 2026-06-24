// 📁 lib/presentation/admin_hopital/analytics/widgets/radiology_ai_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class RadiologyAIViewer extends ConsumerStatefulWidget {
  final String imageUrl;
  final String patientName;
  final String examType;
  final DateTime examDate;
  final List<Map<String, dynamic>> findings;
  final VoidCallback? onFullScreen;

  const RadiologyAIViewer({
    Key? key,
    required this.imageUrl,
    required this.patientName,
    required this.examType,
    required this.examDate,
    required this.findings,
    this.onFullScreen,
  }) : super(key: key);

  @override
  ConsumerState<RadiologyAIViewer> createState() => _RadiologyAIViewerState();
}

class _RadiologyAIViewerState extends ConsumerState<RadiologyAIViewer> {
  String _selectedFinding = 'all';
  bool _showHeatmap = false;
  double _zoom = 1.0;

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
              const Icon(Icons.radiology, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Analyse radiologique IA',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Analyse terminée',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Image et annotations
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
                colorFilter: _showHeatmap
                    ? const ColorFilter.mode(Colors.red, BlendMode.modulate)
                    : null,
              ),
            ),
            child: Stack(
              children: [
                // Annotations IA (simulées)
                Positioned(
                  top: 30,
                  left: 50,
                  child: _buildAnnotation('Anomalie détectée', Colors.red),
                ),
                Positioned(
                  top: 80,
                  right: 40,
                  child: _buildAnnotation('Zone suspecte', Colors.orange),
                ),
                Positioned(
                  bottom: 40,
                  left: 100,
                  child: _buildAnnotation('Nodule', Colors.yellow),
                ),
                // Contrôles sur l'image
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                          onPressed: () => setState(() => _zoom *= 1.1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_out, color: Colors.white, size: 18),
                          onPressed: () => setState(() => _zoom /= 1.1),
                        ),
                        IconButton(
                          icon: Icon(
                            _showHeatmap ? Icons.heat_pump : Icons.heat_pump_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Informations
          Row(
            children: [
              _buildInfoChip(Icons.person, widget.patientName, Colors.blue),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.medical_services, widget.examType, Colors.purple),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.calendar_today, '${widget.examDate.day}/${widget.examDate.month}/${widget.examDate.year}', Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          // Résultats de l'IA
          const Text(
            'Résultats de l\'analyse IA',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: widget.findings.map((finding) {
                final isHigh = finding['confidence'] >= 0.8;
                final isMedium = finding['confidence'] >= 0.5;
                final color = isHigh ? Colors.red : (isMedium ? Colors.orange : Colors.green);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 30,
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              finding['name'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              finding['description'],
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(finding['confidence'] * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
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
          if (widget.onFullScreen != null)
            AdminGradientButton(
              text: 'Voir en plein écran',
              onPressed: widget.onFullScreen,
              icon: Icons.fullscreen,
              height: 38,
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnotation(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
