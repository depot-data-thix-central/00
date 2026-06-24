// 📁 lib/presentation/admin_hopital/appointments/widgets/appointment_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../data/models/hospital/appointment_model.dart';

class AppointmentCalendar extends ConsumerStatefulWidget {
  final Function(DateTime) onDaySelected;
  final Map<DateTime, List<AppointmentModel>>? events;
  final DateTime? focusedDay;
  final DateTime? selectedDay;

  const AppointmentCalendar({
    Key? key,
    required this.onDaySelected,
    this.events,
    this.focusedDay,
    this.selectedDay,
  }) : super(key: key);

  @override
  ConsumerState<AppointmentCalendar> createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends ConsumerState<AppointmentCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<AppointmentModel>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    if (widget.events != null) {
      _events = widget.events!;
    }
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
          const Text(
            'Calendrier des rendez-vous',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              widget.onDaySelected(selected);
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              final events = _events[key] ?? [];
              // Retourne une liste de strings pour l'affichage des marqueurs
              return events.map((e) => e.patientName).toList();
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(fontSize: 13),
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_events[_selectedDay] != null && _events[_selectedDay]!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 4),
                Text(
                  'Rendez-vous du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ..._events[_selectedDay]!.map((appointment) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${appointment.patientName} - ${appointment.doctorName}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        appointment.time,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )),
              ],
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucun rendez-vous ce jour',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
