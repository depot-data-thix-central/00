// 📁 lib/presentation/admin_hopital/advanced_clinics/screens/triage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/triage_scale_widget.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class TriageScreen extends ConsumerStatefulWidget {
  final String? patientId;
  final String? patientName;

  const TriageScreen({Key? key, this.patientId, this.patientName}) : super(key: key);

  @override
  ConsumerState<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends ConsumerState<TriageScreen> {
  bool _isLoading = false;
  TriageLevel? _assignedLevel;
  Map<String, dynamic>? _triageData;

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? 'Patient inconnu';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tri des urgences - $patientName'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_assignedLevel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _assignedLevel!.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _assignedLevel!.label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Enregistrement du tri...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TriageScaleWidget(
                patientName: patientName,
                patientId: widget.patientId,
                onTriageComplete: (level, data) {
                  setState(() {
                    _assignedLevel = level;
                    _triageData = data;
                  });
                  // Sauvegarder automatiquement
                  _saveTriage(level, data);
                },
              ),
              const SizedBox(height: 16),
              if (_assignedLevel != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tri effectué: ${_assignedLevel!.label}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Catégorie ${_assignedLevel!.category} - ${_assignedLevel!.description}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      AdminGradientButton(
                        text: 'Voir détail',
                        onPressed: () {
                          _showTriageDetail();
                        },
                        height: 34,
                        width: 120,
                        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTriage(TriageLevel level, Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));
      // Ici, appeler le repository pour sauvegarder
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tri enregistré: ${level.label}'),
            backgroundColor: level.color,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTriageDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du tri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._triageData!.entries.map((entry) {
              if (entry.key == 'triageLevel' || entry.key == 'category') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        _getLabel(entry.key),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            AdminGradientButton(
              text: 'Fermer',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(String key) {
    switch (key) {
      case 'glasgowScore':
        return 'Glasgow';
      case 'temperature':
        return 'Température';
      case 'heartRate':
        return 'Pouls';
      case 'respiratoryRate':
        return 'FR';
      case 'systolicBP':
        return 'TA systolique';
      case 'diastolicBP':
        return 'TA diastolique';
      case 'painScore':
        return 'Douleur';
      case 'chiefComplaint':
        return 'Motif';
      case 'additionalNotes':
        return 'Notes';
      default:
        return key;
    }
  }
}
