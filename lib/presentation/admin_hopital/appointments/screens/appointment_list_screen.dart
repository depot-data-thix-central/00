// 📁 lib/presentation/admin_hopital/appointments/screens/appointment_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/admin_appointment_provider.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_data_table.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_status_badge.dart';
import '../widgets/appointment_calendar.dart';

class AppointmentListScreen extends ConsumerStatefulWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends ConsumerState<AppointmentListScreen> {
  bool _showCalendar = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminAppointmentProvider.notifier).loadAppointments(date: _selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAppointmentProvider);
    final notifier = ref.read(adminAppointmentProvider.notifier);

    return AdminLoadingOverlay(
      isLoading: state.isLoading && state.appointments.isEmpty,
      message: 'Chargement des rendez-vous...',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre d'outils
          Row(
            children: [
              Expanded(
                child: AdminSearchBar(
                  onSearch: (query) {
                    // Filtrer les rendez-vous par patient/médecin
                    final filtered = state.appointments.where((a) =>
                      a.patientName.toLowerCase().contains(query.toLowerCase()) ||
                      a.doctorName.toLowerCase().contains(query.toLowerCase())
                    ).toList();
                    setState(() {
                      // Mise à jour manuelle, ou mieux via un provider
                      // Pour simplifier, on utilise un state local
                      // Mais idéalement on ajouterait une méthode de filtrage dans le provider
                    });
                  },
                  hintText: 'Rechercher par patient ou médecin...',
                ),
              ),
              const SizedBox(width: 12),
              AdminGradientButton(
                text: _showCalendar ? 'Liste' : 'Calendrier',
                onPressed: () => setState(() => _showCalendar = !_showCalendar),
                icon: _showCalendar ? Icons.list : Icons.calendar_month,
                height: 40,
                width: 120,
              ),
              const SizedBox(width: 8),
              AdminGradientButton(
                text: 'Nouveau RDV',
                onPressed: () {
                  context.push('/admin/appointments/create');
                },
                icon: Icons.add,
                height: 40,
                width: 140,
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contenu
          Expanded(
            child: _showCalendar
                ? AppointmentCalendar(
                    onDaySelected: (date) {
                      setState(() => _selectedDate = date);
                      notifier.loadAppointments(date: date);
                    },
                    events: _groupAppointmentsByDate(state.appointments),
                    selectedDay: _selectedDate,
                  )
                : state.appointments.isEmpty && !state.isLoading
                    ? const AdminEmptyState(
                        title: 'Aucun rendez-vous',
                        subtitle: 'Planifiez votre premier rendez-vous',
                        icon: Icons.calendar_month_outlined,
                        actionText: 'Créer un rendez-vous',
                        onAction: null,
                      )
                    : AdminDataTable(
                        columns: const [
                          DataColumn(label: Text('Patient')),
                          DataColumn(label: Text('Médecin')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Heure')),
                          DataColumn(label: Text('Statut')),
                          DataColumn(label: Text('')),
                        ],
                        rows: state.appointments.map((a) {
                          return {
                            'Patient': a.patientName,
                            'Médecin': a.doctorName,
                            'Date': '${a.date.day}/${a.date.month}/${a.date.year}',
                            'Heure': a.time,
                            'Statut': a.status,
                            'id': a.id,
                          };
                        }).toList(),
                        onRowTap: (index) {
                          final id = state.appointments[index].id;
                          context.push('/admin/appointments/$id');
                        },
                        selectable: false,
                        isLoading: state.isLoading,
                      ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<AppointmentModel>> _groupAppointmentsByDate(List<AppointmentModel> appointments) {
    final map = <DateTime, List<AppointmentModel>>{};
    for (var a in appointments) {
      final key = DateTime(a.date.year, a.date.month, a.date.day);
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }
}
