// 📁 lib/presentation/admin_hopital/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard_kpi_card.dart';
import '../widgets/dashboard_activity_feed.dart';
import '../widgets/dashboard_calendar.dart';
import '../widgets/dashboard_alert_list.dart';
import '../../common/providers/admin_dashboard_provider.dart';
import '../../common/providers/admin_appointment_provider.dart';
import '../../common/providers/admin_operation_provider.dart';
import '../../common/providers/admin_bed_provider.dart';
import '../../../common/widgets/admin_loading_overlay.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminDashboardProvider.notifier).loadDashboard();
      ref.read(adminAppointmentProvider.notifier).loadAppointments();
      ref.read(adminOperationProvider.notifier).loadOperations();
      ref.read(adminBedProvider.notifier).loadBeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(adminDashboardProvider);

    return AdminLoadingOverlay(
      isLoading: dashboardState.isLoading,
      message: 'Chargement du tableau de bord...',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            const Text(
              'Tableau de bord',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vue d\'ensemble de l\'activité de l\'hôpital',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // KPIs - 4 cartes
            _buildKpiRow(context),

            const SizedBox(height: 24),

            // Deux colonnes : Calendrier et Activité récente
            _buildMainContent(context),

            const SizedBox(height: 24),

            // Alertes
            const DashboardAlertList(),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context) {
    final dashboardState = ref.watch(adminDashboardProvider);

    // Données extraites du provider
    final totalPatients = dashboardState.totalPatients;
    final newPatientsToday = dashboardState.newPatientsToday;
    final consultationsToday = dashboardState.consultationsToday;
    final bedOccupancyRate = dashboardState.bedOccupancyRate;

    // Nombre de lits occupés calculé à partir du taux
    final occupiedBeds = (bedOccupancyRate * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pour le web, on peut afficher 4 cartes sur une ligne
        // Si l'écran est petit, on passe en wrap
        final width = constraints.maxWidth;
        final crossAxisCount = width > 800 ? 4 : (width > 500 ? 2 : 1);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            DashboardKpiCard(
              label: 'Patients total',
              value: totalPatients.toString(),
              icon: Icons.people,
              color: Colors.blue,
              trend: 12.5,
              trendLabel: 'vs mois dernier',
              onTap: () {
                // Naviguer vers la liste des patients
              },
            ),
            DashboardKpiCard(
              label: 'Nouveaux patients',
              value: newPatientsToday.toString(),
              icon: Icons.person_add,
              color: Colors.green,
              trend: 8.2,
              trendLabel: 'vs hier',
              onTap: () {
                // Naviguer vers les admissions
              },
            ),
            DashboardKpiCard(
              label: 'Consultations du jour',
              value: consultationsToday.toString(),
              icon: Icons.medical_services,
              color: Colors.purple,
              trend: -2.1,
              trendLabel: 'vs hier',
              onTap: () {
                // Naviguer vers les consultations
              },
            ),
            DashboardKpiCard(
              label: 'Taux d\'occupation',
              value: '$occupiedBeds%',
              icon: Icons.bed,
              color: occupiedBeds > 80 ? Colors.red : Colors.orange,
              trend: occupiedBeds > 80 ? -5.0 : 3.2,
              trendLabel: 'vs semaine dernière',
              onTap: () {
                // Naviguer vers la gestion des lits
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: const DashboardCalendar(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: const DashboardActivityFeed(),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              const DashboardCalendar(),
              const SizedBox(height: 24),
              const DashboardActivityFeed(),
            ],
          );
        }
      },
    );
  }
}
