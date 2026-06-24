// 📁 lib/presentation/admin_hopital/advanced_clinics/screens/dialysis_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dialysis_session_tracker.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class DialysisScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const DialysisScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  ConsumerState<DialysisScreen> createState() => _DialysisScreenState();
}

class _DialysisScreenState extends ConsumerState<DialysisScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _sessions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dialyse - ${widget.patientName}'),
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
              DialysisSessionTracker(
                patientId: widget.patientId,
                patientName: widget.patientName,
                onSessionSaved: (data) {
                  setState(() {
                    _sessions.add(data);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session de dialyse enregistrée'), backgroundColor: Colors.green),
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
                      const Icon(Icons.health_and_safety, size: 18, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s['sessionType']} - ${s['status']}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Date: ${(s['sessionDate'] as DateTime).day}/${(s['sessionDate'] as DateTime).month}/${(s['sessionDate'] as DateTime).year}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${s['duration'] ?? 0} min',
                        style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                AdminGradientButton(
                  text: 'Voir toutes les sessions',
                  onPressed: () {},
                  height: 38,
                  width: 200,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
