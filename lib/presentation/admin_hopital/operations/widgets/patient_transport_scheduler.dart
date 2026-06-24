// 📁 lib/presentation/admin_hopital/operations/widgets/patient_transport_scheduler.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class PatientTransportScheduler extends StatefulWidget {
  final Function(Map<String, dynamic>) onSchedule;
  final VoidCallback? onCancel;

  const PatientTransportScheduler({
    Key? key,
    required this.onSchedule,
    this.onCancel,
  }) : super(key: key);

  @override
  State<PatientTransportScheduler> createState() => _PatientTransportSchedulerState();
}

class _PatientTransportSchedulerState extends State<PatientTransportScheduler> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _patientCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Valeurs
  String _transportType = 'Brancard';
  String _priority = 'normal';
  String _status = 'planned';
  DateTime? _scheduleDate;
  DateTime? _scheduleTime;

  final List<String> _transportTypes = ['Brancard', 'Fauteuil roulant', 'Ambulance', 'Transfert interne'];
  final List<String> _priorities = ['normal', 'urgent', 'critical'];
  final List<String> _statuses = ['planned', 'in_progress', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _scheduleDate = DateTime.now();
    _scheduleTime = DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Transport de patients',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdminFormField(
              label: 'Patient *',
              controller: _patientCtrl,
              hint: 'Nom du patient',
              validator: (v) => v?.isEmpty == true ? 'Patient requis' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Départ *',
                    controller: _fromCtrl,
                    hint: 'Service/Chambre',
                    validator: (v) => v?.isEmpty == true ? 'Départ requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminFormField(
                    label: 'Arrivée *',
                    controller: _toCtrl,
                    hint: 'Destination',
                    validator: (v) => v?.isEmpty == true ? 'Arrivée requise' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Type de transport',
                    value: _transportType,
                    items: _transportTypes.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _transportType = v ?? _transportType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Priorité',
                    value: _priority,
                    items: _priorities.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p == 'critical' ? Colors.red : (p == 'urgent' ? Colors.orange : Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(_getPriorityLabel(p), style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _scheduleDate != null
                            ? '${_scheduleDate!.day}/${_scheduleDate!.month}/${_scheduleDate!.year}'
                            : 'Sélectionner',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _scheduleDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _scheduleDate = picked);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text(
                        'Heure',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _scheduleTime != null
                            ? '${_scheduleTime!.hour.toString().padLeft(2, '0')}:${_scheduleTime!.minute.toString().padLeft(2, '0')}'
                            : 'Sélectionner',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.access_time, size: 18),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_scheduleTime ?? DateTime.now()),
                        );
                        if (picked != null) {
                          final now = DateTime.now();
                          setState(() {
                            _scheduleTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AdminDropdown<String>(
              label: 'Statut',
              value: _status,
              items: _statuses.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(_getStatusLabel(s), style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            AdminFormField(
              label: 'Notes',
              controller: _notesCtrl,
              hint: 'Informations supplémentaires...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AdminGradientButton(
                    text: 'Planifier le transport',
                    onPressed: _scheduleTransport,
                    icon: Icons.schedule,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  ),
                ),
                if (widget.onCancel != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'critical':
        return 'Critique';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Normal';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planned':
        return 'Planifié';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  void _scheduleTransport() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'patient': _patientCtrl.text,
      'from': _fromCtrl.text,
      'to': _toCtrl.text,
      'transportType': _transportType,
      'priority': _priority,
      'scheduleDate': _scheduleDate,
      'scheduleTime': _scheduleTime,
      'status': _status,
      'notes': _notesCtrl.text,
    };
    widget.onSchedule(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transport planifié'), backgroundColor: Colors.green),
    );
  }
}
