// 📁 lib/presentation/admin_hopital/advanced_clinics/screens/rehabilitation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/rehabilitation_session_card.dart';
import '../../common/widgets/admin_loading_overlay.dart';

class RehabilitationScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final String therapistName;

  const RehabilitationScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
    this.therapistName = 'Dr. Martin',
  }) : super(key: key);

  @override
  ConsumerState<RehabilitationScreen> createState() => _RehabilitationScreenState();
}

class _RehabilitationScreenState extends ConsumerState<RehabilitationScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _sessions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rééducation - ${widget.patientName}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historique des sessions'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Historique',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Enregistrement de la session...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RehabilitationSessionCard(
                patientId: widget.patientId,
                patientName: widget.patientName,
                therapistName: widget.therapistName,
                onSessionSaved: (data) {
                  setState(() {
                    _sessions.add(data);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session de rééducation enregistrée'), backgroundColor: Colors.green),
                  );
                },
              ),
              if (_sessions.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Sessions récentes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ..._sessions.take(3).map((s) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 18, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s['sessionType']} - ${s['intensity']}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Date: ${(s['sessionDate'] as DateTime).day}/${(s['sessionDate'] as DateTime).month}/${(s['sessionDate'] as DateTime).year}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              'Exercices: ${(s['exercises'] as List).join(', ')}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
                          s['status'] ?? 'Terminée',
                          style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
