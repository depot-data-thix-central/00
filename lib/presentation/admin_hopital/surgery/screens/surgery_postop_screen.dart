// 📁 lib/presentation/admin_hopital/surgery/screens/surgery_postop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/surgery_postop_report.dart';
import '../../common/providers/admin_operation_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SurgeryPostopScreen extends ConsumerStatefulWidget {
  final String operationId;

  const SurgeryPostopScreen({
    Key? key,
    required this.operationId,
  }) : super(key: key);

  @override
  ConsumerState<SurgeryPostopScreen> createState() => _SurgeryPostopScreenState();
}

class _SurgeryPostopScreenState extends ConsumerState<SurgeryPostopScreen> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationProvider);
    final operation = state.operations.firstWhere(
      (o) => o.id == widget.operationId,
      orElse: () => null,
    );

    if (state.isLoading && state.operations.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (operation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Intervention non trouvée')),
        body: const Center(child: Text('Cette intervention n\'existe pas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post-opératoire - ${operation.patientName}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaved)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SurgeryPostopReport(
              patientName: operation.patientName,
              surgeryType: operation.type,
              surgeon: operation.surgeonName,
              onSave: (data) {
                setState(() => _isSaved = true);
                // Mettre à jour le statut de l'opération
                ref.read(adminOperationProvider.notifier)
                    .updateOperationStatus(widget.operationId, 'completed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compte rendu post-opératoire enregistré'), backgroundColor: Colors.green),
                );
              },
            ),
            const SizedBox(height: 16),

            if (_isSaved)
              AdminGradientButton(
                text: 'Terminer la procédure',
                onPressed: () {
                  context.pop();
                  context.pop();
                },
                icon: Icons.done_all,
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              ),
          ],
        ),
      ),
    );
  }
}
