// 📁 lib/presentation/admin_hopital/appointments/screens/appointment_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_appointment_provider.dart';
import '../../common/providers/admin_patient_provider.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../common/widgets/admin_form_field.dart';
import '../../common/widgets/admin_dropdown.dart';
import '../../common/widgets/admin_date_picker.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../widgets/appointment_slot_picker.dart';
import '../../../../data/models/hospital/appointment_model.dart';

class AppointmentCreateScreen extends ConsumerStatefulWidget {
  const AppointmentCreateScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentCreateScreen> createState() => _AppointmentCreateScreenState();
}

class _AppointmentCreateScreenState extends ConsumerState<AppointmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Contrôleurs
  final _notesCtrl = TextEditingController();

  // Valeurs
  String? _selectedPatientId;
  String? _selectedDoctorId;
  DateTime? _selectedDate;
  DateTime? _selectedDateTime;

  List<PatientModel> _patients = [];
  List<StaffModel> _doctors = [];
  List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Charger les patients et les médecins
    await ref.read(adminPatientProvider.notifier).loadPatients();
    await ref.read(adminStaffProvider.notifier).loadStaff();
    final patientState = ref.read(adminPatientProvider);
    final staffState = ref.read(adminStaffProvider);
    setState(() {
      _patients = patientState.patients;
      _doctors = staffState.staff.where((s) => s.role == 'doctor').toList();
    });
  }

  Future<void> _loadBookedSlots(DateTime date) async {
    // Simuler des créneaux réservés (à remplacer par un vrai appel API)
    // Dans la vraie vie, on interrogerait les rendez-vous existants pour ce médecin et cette date
    setState(() {
      _bookedSlots = ['09:00', '10:30', '14:00']; // Exemple
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau rendez-vous'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: AdminLoadingOverlay(
        isLoading: _patients.isEmpty && _doctors.isEmpty && !ref.watch(adminPatientProvider).isLoading,
        message: 'Chargement des données...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Planifier un rendez-vous',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Sélection du patient
                AdminDropdown<String>(
                  label: 'Patient *',
                  value: _selectedPatientId,
                  items: _patients.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(p.fullName, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedPatientId = v),
                  hint: 'Sélectionner un patient',
                  isSearchable: true,
                ),
                const SizedBox(height: 12),

                // Sélection du médecin
                AdminDropdown<String>(
                  label: 'Médecin *',
                  value: _selectedDoctorId,
                  items: _doctors.map((d) {
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text('${d.fullName} (${d.specialty})', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedDoctorId = v;
                      if (_selectedDate != null) {
                        _loadBookedSlots(_selectedDate!);
                      }
                    });
                  },
                  hint: 'Sélectionner un médecin',
                  isSearchable: true,
                ),
                const SizedBox(height: 12),

                // Date du rendez-vous
                AdminDatePicker(
                  label: 'Date du rendez-vous *',
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedDateTime = null;
                      if (_selectedDoctorId != null) {
                        _loadBookedSlots(date!);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Créneaux horaires
                if (_selectedDate != null && _selectedDoctorId != null)
                  AppointmentSlotPicker(
                    selectedDate: _selectedDate,
                    bookedSlots: _bookedSlots,
                    onSlotSelected: (fullDateTime) {
                      setState(() => _selectedDateTime = fullDateTime);
                    },
                  ),
                const SizedBox(height: 12),

                // Notes
                AdminFormField(
                  label: 'Notes',
                  controller: _notesCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: AdminGradientButton(
                        text: _isSubmitting ? 'Création...' : 'Créer le rendez-vous',
                        onPressed: _isSubmitting ? null : _submitForm,
                        icon: _isSubmitting ? null : Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Annuler', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un patient'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un médecin'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un créneau horaire'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final patient = _patients.firstWhere((p) => p.id == _selectedPatientId);
      final doctor = _doctors.firstWhere((d) => d.id == _selectedDoctorId);

      final appointment = AppointmentModel(
        id: '',
        patientId: patient.id,
        patientName: patient.fullName,
        doctorId: doctor.id,
        doctorName: doctor.fullName,
        specialty: doctor.specialty,
        date: _selectedDateTime!,
        time: '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
        status: 'pending',
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(adminAppointmentProvider.notifier).createAppointment(appointment);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous créé avec succès'), backgroundColor: Colors.green),
        );
        context.pop();
        // Rafraîchir la liste
        ref.read(adminAppointmentProvider.notifier).loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
