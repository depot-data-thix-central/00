// 📁 lib/presentation/admin_hopital/analytics/screens/radiology_ai_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/radiology_ai_viewer.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';

class RadiologyAIScreen extends ConsumerStatefulWidget {
  final String? examId;

  const RadiologyAIScreen({Key? key, this.examId}) : super(key: key);

  @override
  ConsumerState<RadiologyAIScreen> createState() => _RadiologyAIScreenState();
}

class _RadiologyAIScreenState extends ConsumerState<RadiologyAIScreen> {
  bool _isLoading = true;
  String _searchQuery = '';

  // Données mockées pour la liste des examens
  final List<Map<String, dynamic>> _exams = [
    {
      'id': '1',
      'patientName': 'Michel Dupont',
      'examType': 'Scanner thoracique',
      'examDate': DateTime.now().subtract(const Duration(days: 1)),
      'imageUrl': 'https://placehold.co/600x400/blue/white?text=Scanner',
      'findings': [
        {'name': 'Nodule suspect', 'description': 'Nodule de 8mm au lobe supérieur droit', 'confidence': 0.85},
        {'name': 'Adénopathies', 'description': 'Adénopathies médiastinales', 'confidence': 0.72},
        {'name': 'Épanchement pleural', 'description': 'Épanchement pleural minime', 'confidence': 0.45},
      ],
    },
    {
      'id': '2',
      'patientName': 'Sophie Martin',
      'examType': 'IRM cérébrale',
      'examDate': DateTime.now().subtract(const Duration(days: 3)),
      'imageUrl': 'https://placehold.co/600x400/green/white?text=IRM',
      'findings': [
        {'name': 'Lésion hyperintense', 'description': 'Lésion en T2 FLAIR au niveau temporal', 'confidence': 0.88},
        {'name': 'Atrophie corticale', 'description': 'Atrophie modérée', 'confidence': 0.65},
      ],
    },
    {
      'id': '3',
      'patientName': 'Lucas Bernard',
      'examType': 'Radiographie thoracique',
      'examDate': DateTime.now().subtract(const Duration(days: 5)),
      'imageUrl': 'https://placehold.co/600x400/orange/white?text=Radio',
      'findings': [
        {'name': 'Opacité alvéolaire', 'description': 'Opacité de type alvéolaire à la base droite', 'confidence': 0.78},
        {'name': 'Épanchement', 'description': 'Épanchement pleural droit', 'confidence': 0.55},
      ],
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

  List<Map<String, dynamic>> get _filteredExams {
    if (_searchQuery.isEmpty) return _exams;
    final query = _searchQuery.toLowerCase();
    return _exams.where((e) =>
      e['patientName'].toLowerCase().contains(query) ||
      e['examType'].toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExams;

    // Si un examId est fourni, afficher directement le viewer
    if (widget.examId != null) {
      final exam = _exams.firstWhere((e) => e['id'] == widget.examId, orElse: () => _exams.first);
      return Scaffold(
        appBar: AppBar(
          title: Text('Analyse IA - ${exam['patientName']}'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: RadiologyAIViewer(
            imageUrl: exam['imageUrl'],
            patientName: exam['patientName'],
            examType: exam['examType'],
            examDate: exam['examDate'],
            findings: exam['findings'],
            onFullScreen: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mode plein écran'), backgroundColor: Colors.blue),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse radiologique IA'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des examens...',
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AdminSearchBar(
                onSearch: (query) => setState(() => _searchQuery = query),
                hintText: 'Rechercher un examen (patient, type)...',
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(
                      title: 'Aucun examen',
                      subtitle: 'Aucun examen radiologique à analyser',
                      icon: Icons.radiology_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final exam = filtered[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, size: 30, color: Colors.blue),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam['patientName'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      exam['examType'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${exam['examDate'].day}/${exam['examDate'].month}/${exam['examDate'].year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${exam['findings'].length} anomalies',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminGradientButton(
                                text: 'Analyser',
                                onPressed: () {
                                  context.push('/admin/analytics/radiology/${exam['id']}');
                                },
                                height: 34,
                                width: 80,
                                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
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
