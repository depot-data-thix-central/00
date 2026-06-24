// 📁 lib/presentation/admin_hopital/surgery/screens/surgery_preop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/surgery_preop_checklist.dart';
import '../../common/providers/admin_operation_provider.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SurgeryPreopScreen extends ConsumerStatefulWidget {
  final String operationId;

  const SurgeryPreopScreen({
    Key? key,
    required this.operationId,
  }) : super(key: key);

  @override
  ConsumerState<SurgeryPreopScreen> createState() => _SurgeryPreopScreenState();
}

class _SurgeryPreopScreenState extends ConsumerState<SurgeryPreopScreen> {
  bool _isCompleted = false;

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
        title: Text('Pré-opératoire - ${operation.patientName}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isCompleted)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Checklist
            SurgeryPreopChecklist(
              patientName: operation.patientName,
              surgeryType: operation.type,
              surgeon: operation.surgeonName,
              surgeryDate: operation.scheduledDate,
              onComplete: (completed) {
                setState(() => _isCompleted = completed);
                if (completed) {
                  // Mettre à jour le statut de l'opération
                  ref.read(adminOperationProvider.notifier)
                      .updateOperationStatus(widget.operationId, 'in_progress');
                }
              },
            ),
            const SizedBox(height: 16),

            // Informations complémentaires
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Informations pré-opératoires',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Patient', operation.patientName),
                  _buildInfoRow('Intervention', operation.type),
                  _buildInfoRow('Chirurgien', operation.surgeonName),
                  _buildInfoRow('Salle', operation.room),
                  _buildInfoRow('Date', '${operation.scheduledDate.day}/${operation.scheduledDate.month}/${operation.scheduledDate.year}'),
                  _buildInfoRow('Heure', '${operation.scheduledDate.hour.toString().padLeft(2, '0')}:${operation.scheduledDate.minute.toString().padLeft(2, '0')}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_isCompleted)
              AdminGradientButton(
                text: 'Démarrer l\'intervention',
                onPressed: () {
                  context.push('/admin/surgery/${widget.operationId}/postop');
                },
                icon: Icons.surgery,
                gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
