// 📁 lib/presentation/admin_hopital/dashboard/widgets/dashboard_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../common/providers/admin_appointment_provider.dart';
import '../../../common/providers/admin_operation_provider.dart';

class DashboardCalendar extends ConsumerStatefulWidget {
  const DashboardCalendar({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends ConsumerState<DashboardCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final appointments = await ref.read(adminAppointmentProvider.notifier).loadAppointments();
    final operations = await ref.read(adminOperationProvider.notifier).loadOperations();

    final events = <DateTime, List<String>>{};
    // Simuler l'ajout d'événements (à connecter avec les vrais providers)
    // Dans la vraie vie, on utiliserait les données des providers.
    // On va juste ajouter des exemples pour la démonstration.
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final day = now.add(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      events[key] = ['Consultation Dr. Martin', 'Examen IRM'];
    }
    if (mounted) {
      setState(() => _events = events);
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
            'Calendrier',
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
              // Ici on pourrait naviguer vers la liste des événements du jour
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return _events[key] ?? [];
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
                  'Événements du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                ..._events[_selectedDay]!.map((event) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        event,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }
}
