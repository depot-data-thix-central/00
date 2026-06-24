// 📁 lib/presentation/admin_hopital/patients/screens/patient_admission_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/patient_admission_form.dart';

class PatientAdmissionScreen extends ConsumerWidget {
  const PatientAdmissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission d\'un patient'),
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
        child: PatientAdmissionForm(
          onSuccess: () {
            // Après admission, revenir à la liste
            context.pop();
            // Optionnel : rafraîchir la liste
            ref.read(adminPatientProvider.notifier).loadPatients();
          },
          onCancel: () {
            context.pop();
          },
        ),
      ),
    );
  }
}
