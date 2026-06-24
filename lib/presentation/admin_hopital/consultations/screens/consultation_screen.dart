// 📁 lib/presentation/admin_hopital/consultations/screens/consultation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/consultation_vital_signs.dart';
import '../widgets/consultation_prescription.dart';
import '../widgets/consultation_exam_order.dart';
import '../widgets/consultation_note_editor.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/providers/admin_appointment_provider.dart';
import '../../../common/widgets/admin_loading_overlay.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../../data/models/hospital/consultation_model.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  final String? patientId;
  final String? appointmentId;

  const ConsultationScreen({
    Key? key,
    this.patientId,
    this.appointmentId,
  }) : super(key: key);

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;
  bool _isLoading = true;

  // Données de la consultation
  VitalSignsData? _vitalSigns;
  List<PrescriptionItem> _prescriptions = [];
  List<ExamOrderItem> _examOrders = [];
  String _motif = '';
  String _diagnostic = '';
  String _treatment = '';

  // Patient et rendez-vous
  String _patientName = 'Patient inconnu';
  String _patientId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger les infos du patient
      if (widget.patientId != null) {
        final patient = await ref.read(adminPatientProvider.notifier).getPatientById(widget.patientId!);
        if (patient != null) {
          setState(() {
            _patientName = patient.fullName;
            _patientId = patient.id;
          });
        }
      } else if (widget.appointmentId != null) {
        // Charger depuis le rendez-vous
        final apptState = ref.read(adminAppointmentProvider);
        final appointment = apptState.appointments.firstWhere(
          (a) => a.id == widget.appointmentId,
          orElse: () => null,
        );
        if (appointment != null) {
          setState(() {
            _patientName = appointment.patientName;
            _patientId = appointment.patientId;
          });
        }
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultation - $_patientName'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'Signes vitaux'),
            Tab(text: 'Prescription'),
            Tab(text: 'Examens'),
            Tab(text: 'Compte rendu'),
          ],
        ),
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading || _isSaving,
        message: _isSaving ? 'Enregistrement en cours...' : 'Chargement...',
        child: TabBarView(
          controller: _tabController,
          children: [
            // Signes vitaux
            ConsultationVitalSigns(
              onSave: (data) {
                setState(() => _vitalSigns = data);
                // Optionnel : afficher un snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signes vitaux enregistrés'), backgroundColor: Colors.green),
                );
              },
            ),
            // Prescription
            ConsultationPrescription(
              onSave: (prescriptions) {
                setState(() => _prescriptions = prescriptions);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prescription enregistrée'), backgroundColor: Colors.green),
                );
              },
            ),
            // Examens
            ConsultationExamOrder(
              onSave: (orders) {
                setState(() => _examOrders = orders);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Examens enregistrés'), backgroundColor: Colors.green),
                );
              },
            ),
            // Compte rendu
            ConsultationNoteEditor(
              onSave: (motif, diagnostic, treatment) {
                setState(() {
                  _motif = motif;
                  _diagnostic = diagnostic;
                  _treatment = treatment;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compte rendu enregistré'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: AdminGradientButton(
                text: 'Finaliser la consultation',
                onPressed: _finalizeConsultation,
                icon: Icons.check_circle,
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Annuler', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizeConsultation() async {
    // Vérifier que les données minimales sont présentes
    if (_motif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le motif dans le compte rendu'), backgroundColor: Colors.orange),
      );
      _tabController.index = 3;
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Construire l'objet consultation
      final consultation = ConsultationModel(
        id: '',
        patientId: _patientId,
        patientName: _patientName,
        doctorId: 'current_doctor_id', // À récupérer de l'auth
        doctorName: 'Dr. En cours', // À récupérer de l'auth
        date: DateTime.now(),
        motif: _motif,
        diagnostic: _diagnostic,
        traitement: _treatment,
        vitalSigns: _vitalSigns?.toJson() ?? {},
        prescriptions: _prescriptions.map((p) => p.toJson()).toList(),
        examOrders: _examOrders.map((e) => e.toJson()).toList(),
        status: 'completed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Ici, appeler le repository pour sauvegarder
      // await ref.read(consultationRepositoryProvider).createConsultation(consultation);

      // Simuler un délai
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation finalisée avec succès'), backgroundColor: Colors.green),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
