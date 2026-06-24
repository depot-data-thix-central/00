// 📁 lib/presentation/admin_hopital/staff/widgets/staff_schedule_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../common/providers/admin_staff_provider.dart';
import '../../../../data/models/hospital/staff_model.dart';

class StaffScheduleCalendar extends ConsumerStatefulWidget {
  final String? staffId;
  final Function(DateTime)? onDaySelected;

  const StaffScheduleCalendar({
    Key? key,
    this.staffId,
    this.onDaySelected,
  }) : super(key: key);

  @override
  ConsumerState<StaffScheduleCalendar> createState() => _StaffScheduleCalendarState();
}

class _StaffScheduleCalendarState extends ConsumerState<StaffScheduleCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    // Simuler le chargement des plannings
    await Future.delayed(const Duration(milliseconds: 500));
    
    final events = <DateTime, List<String>>{};
    final now = DateTime.now();
    // Ajouter des exemples d'événements
    for (int i = 0; i < 7; i++) {
      final day = now.add(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      if (i % 2 == 0) {
        events[key] = ['Consultation 9h-12h', 'Visite 14h-16h'];
      } else {
        events[key] = ['Gardes 20h-8h'];
      }
    }
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

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
              const Icon(Icons.calendar_month, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Planning du personnel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (widget.staffId != null)
                TextButton(
                  onPressed: _loadSchedule,
                  child: const Text('Rafraîchir', style: TextStyle(fontSize: 12)),
                ),
            ],
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
              if (widget.onDaySelected != null) {
                widget.onDaySelected!(selected);
              }
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return _events[key] ?? [];
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(fontSize: 13),
              markerDecoration: const BoxDecoration(
                color: Colors.blue,
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
                  'Activités du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                ..._events[_selectedDay]!.map((event) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event,
                          style: const TextStyle(fontSize: 12),
                        ),
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
                'Aucune activité ce jour',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
