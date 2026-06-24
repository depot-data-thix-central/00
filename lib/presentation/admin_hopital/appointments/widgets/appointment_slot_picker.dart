// 📁 lib/presentation/admin_hopital/appointments/widgets/appointment_slot_picker.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentSlotPicker extends ConsumerStatefulWidget {
  final Function(DateTime) onSlotSelected;
  final DateTime? selectedDate;
  final List<String>? bookedSlots; // ex: ["09:00", "10:30"]

  const AppointmentSlotPicker({
    Key? key,
    required this.onSlotSelected,
    this.selectedDate,
    this.bookedSlots,
  }) : super(key: key);

  @override
  ConsumerState<AppointmentSlotPicker> createState() => _AppointmentSlotPickerState();
}

class _AppointmentSlotPickerState extends ConsumerState<AppointmentSlotPicker> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  final List<String> _slots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '14:00', '14:30', '15:00',
    '15:30', '16:00', '16:30', '17:00', '17:30', '18:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  List<String> get _availableSlots {
    final booked = widget.bookedSlots ?? [];
    return _slots.where((slot) => !booked.contains(slot)).toList();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              Text(
                'Créneaux disponibles - ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_availableSlots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucun créneau disponible pour cette journée',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSlot = slot;
                    });
                    // On construit un DateTime complet avec l'heure sélectionnée
                    final hour = int.parse(slot.split(':')[0]);
                    final minute = int.parse(slot.split(':')[1]);
                    final fullDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      hour,
                      minute,
                    );
                    widget.onSlotSelected(fullDateTime);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
