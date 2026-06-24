// 📁 lib/presentation/admin_hopital/exams/screens/exam_prescription_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/exam_prescription_form.dart';
import '../../common/providers/admin_exam_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/providers/admin_staff_provider.dart';

class ExamPrescriptionScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const ExamPrescriptionScreen({
    Key? key,
    this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<ExamPrescriptionScreen> createState() => _ExamPrescriptionScreenState();
}

class _ExamPrescriptionScreenState extends ConsumerState<ExamPrescriptionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription d\'examens'),
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
        child: ExamPrescriptionForm(
          patientId: widget.patientId,
          onPrescribe: (data) async {
            setState(() => _isLoading = true);
            try {
              // Sauvegarder la prescription
              // Dans la vraie vie, on appellerait le repository
              // Ici on simule
              await Future.delayed(const Duration(seconds: 1));
              // Ajouter les examens au provider
              final examProvider = ref.read(adminExamProvider.notifier);
              for (var examName in data['exams'] as List<String>) {
                await examProvider.addExam(ExamModel(
                  id: '',
                  patientId: data['patientId'],
                  patientName: data['patientName'],
                  doctorId: data['doctorId'],
                  doctorName: data['doctorName'],
                  type: data['examType'],
                  priority: data['priority'],
                  date: data['date'],
                  status: 'pending',
                  notes: data['notes'],
                ));
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Examens prescrits avec succès'), backgroundColor: Colors.green),
                );
                context.pop();
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
          },
        ),
      ),
    );
  }
}
