// 📁 lib/presentation/admin_hopital/operations/widgets/room_booking_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class RoomBookingCalendar extends StatefulWidget {
  final Function(DateTime)? onDaySelected;
  final Function(Map<String, dynamic>)? onBooking;

  const RoomBookingCalendar({
    Key? key,
    this.onDaySelected,
    this.onBooking,
  }) : super(key: key);

  @override
  State<RoomBookingCalendar> createState() => _RoomBookingCalendarState();
}

class _RoomBookingCalendarState extends State<RoomBookingCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _bookings = {};
  bool _isLoading = true;

  // Pour créer une nouvelle réservation
  String _selectedRoom = 'Salle de réunion A';
  String _selectedTimeSlot = '09:00 - 10:00';
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  final List<String> _rooms = [
    'Salle de réunion A',
    'Salle de réunion B',
    'Salle de conférence',
    'Salle de formation',
    'Amphithéâtre',
    'Salle de soins 1',
    'Salle de soins 2',
  ];

  final List<String> _timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    // Simuler le chargement
    await Future.delayed(const Duration(milliseconds: 500));
    final bookings = <DateTime, List<Map<String, dynamic>>>{};
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final day = now.add(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      bookings[key] = [
        {'room': 'Salle de réunion A', 'time': '09:00 - 10:00', 'title': 'Réunion d\'équipe', 'description': 'Point hebdomadaire'},
        {'room': 'Salle de réunion B', 'time': '14:00 - 15:00', 'title': 'Consultation', 'description': 'Patient urgent'},
      ];
    }
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dayBookings = _bookings[_selectedDay] ?? [];

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
              const Icon(Icons.meeting_room, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Réservation des salles',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: _loadBookings,
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
              final events = _bookings[key] ?? [];
              return events.map((e) => '${e['room']} - ${e['title']}').toList();
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
          const SizedBox(height: 12),
          // Réservations du jour
          if (dayBookings.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 4),
            Text(
              'Réservations du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...dayBookings.map((booking) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.meeting_room, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['title'],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${booking['room']} • ${booking['time']}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        if (booking['description'] != null)
                          Text(
                            booking['description'],
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucune réservation ce jour',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 16),
          // Formulaire de réservation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle réservation',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRoom,
                  items: _rooms.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedRoom = v ?? _selectedRoom),
                  decoration: InputDecoration(
                    labelText: 'Salle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTimeSlot,
                  items: _timeSlots.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedTimeSlot = v ?? _selectedTimeSlot),
                  decoration: InputDecoration(
                    labelText: 'Créneau horaire',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Objet de la réservation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Détails supplémentaires',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                AdminGradientButton(
                  text: 'Réserver',
                  onPressed: _bookRoom,
                  icon: Icons.check,
                  height: 34,
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _bookRoom() {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un titre'), backgroundColor: Colors.orange),
      );
      return;
    }
    final data = {
      'room': _selectedRoom,
      'time': _selectedTimeSlot,
      'title': _titleCtrl.text,
      'description': _descriptionCtrl.text,
      'date': _selectedDay,
    };
    if (widget.onBooking != null) {
      widget.onBooking!(data);
    }
    // Ajouter localement
    setState(() {
      final key = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      if (_bookings.containsKey(key)) {
        _bookings[key]!.add(data);
      } else {
        _bookings[key] = [data];
      }
    });
    _titleCtrl.clear();
    _descriptionCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salle réservée'), backgroundColor: Colors.green),
    );
  }
}
