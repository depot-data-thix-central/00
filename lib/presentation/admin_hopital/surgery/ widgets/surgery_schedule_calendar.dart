// 📁 lib/presentation/admin_hopital/surgery/widgets/surgery_schedule_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../common/widgets/admin_status_badge.dart';

class SurgeryScheduleCalendar extends ConsumerStatefulWidget {
  final Function(DateTime)? onDaySelected;
  final Function(String)? onSurgeryTap;

  const SurgeryScheduleCalendar({
    Key? key,
    this.onDaySelected,
    this.onSurgeryTap,
  }) : super(key: key);

  @override
  ConsumerState<SurgeryScheduleCalendar> createState() => _SurgeryScheduleCalendarState();
}

class _SurgeryScheduleCalendarState extends ConsumerState<SurgeryScheduleCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _surgeries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurgeries();
  }

  Future<void> _loadSurgeries() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final surgeries = <DateTime, List<Map<String, dynamic>>>{};
    final now = DateTime.now();

    // Exemples de chirurgies
    final mockSurgeries = [
      {'patient': 'Michel Dupont', 'type': 'Cardiaque', 'surgeon': 'Dr. Martin', 'room': 'Salle 1', 'time': '08:00', 'status': 'scheduled'},
      {'patient': 'Sophie Martin', 'type': 'Orthopédique', 'surgeon': 'Dr. Bernard', 'room': 'Salle 2', 'time': '10:30', 'status': 'in_progress'},
      {'patient': 'Lucas Bernard', 'type': 'Générale', 'surgeon': 'Dr. Petit', 'room': 'Salle 1', 'time': '14:00', 'status': 'scheduled'},
      {'patient': 'Julie Petit', 'type': 'Urologique', 'surgeon': 'Dr. Martin', 'room': 'Salle 3', 'time': '16:30', 'status': 'completed'},
    ];

    for (int i = 0; i < 5; i++) {
      final day = now.add(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      if (i < mockSurgeries.length) {
        surgeries[key] = [mockSurgeries[i]];
      } else if (i == 0) {
        surgeries[key] = [mockSurgeries[0], mockSurgeries[1]];
      }
    }

    setState(() {
      _surgeries = surgeries;
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
              const Icon(Icons.surgery, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Planning opératoire',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: _loadSurgeries,
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
              final events = _surgeries[key] ?? [];
              return events.map((e) => '${e['patient']} - ${e['type']}').toList();
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(fontSize: 13),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
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
          const SizedBox(height: 12),

          // Liste des interventions du jour
          if (_surgeries[_selectedDay] != null && _surgeries[_selectedDay]!.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 4),
            Text(
              'Interventions du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ..._surgeries[_selectedDay]!.map((surgery) => InkWell(
              onTap: () {
                if (widget.onSurgeryTap != null) {
                  widget.onSurgeryTap!(surgery['patient']);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: _getStatusColor(surgery['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(surgery['status']).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 30,
                      color: _getStatusColor(surgery['status']),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surgery['patient'],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${surgery['type']} • Dr. ${surgery['surgeon']} • ${surgery['room']} • ${surgery['time']}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    AdminStatusBadge(
                      status: _getStatusType(surgery['status']),
                      customLabel: _getStatusLabel(surgery['status']),
                      fontSize: 9,
                    ),
                  ],
                ),
              ),
            )),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucune intervention ce jour',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programmé';
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

  StatusType _getStatusType(String status) {
    switch (status) {
      case 'scheduled':
        return StatusType.pending;
      case 'in_progress':
        return StatusType.warning;
      case 'completed':
        return StatusType.completed;
      case 'cancelled':
        return StatusType.cancelled;
      default:
        return StatusType.inactive;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return '📅';
      case 'in_progress':
        return '⏳';
      case 'completed':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '❓';
    }
  }
}
