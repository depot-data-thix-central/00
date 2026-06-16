// 📁 lib/presentation/admin_hopital/common/providers/admin_dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/hospital/dashboard_repository.dart';
import '../../../../core/utils/logger.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

class DashboardState {
  final int totalPatients;
  final int newPatientsToday;
  final int admittedPatients;
  final int consultationsToday;
  final int completedConsultations;
  final double bedOccupancyRate;
  final int upcomingAppointments;
  final int urgentAlerts;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.totalPatients = 0,
    this.newPatientsToday = 0,
    this.admittedPatients = 0,
    this.consultationsToday = 0,
    this.completedConsultations = 0,
    this.bedOccupancyRate = 0.0,
    this.upcomingAppointments = 0,
    this.urgentAlerts = 0,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? totalPatients,
    int? newPatientsToday,
    int? admittedPatients,
    int? consultationsToday,
    int? completedConsultations,
    double? bedOccupancyRate,
    int? upcomingAppointments,
    int? urgentAlerts,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      totalPatients: totalPatients ?? this.totalPatients,
      newPatientsToday: newPatientsToday ?? this.newPatientsToday,
      admittedPatients: admittedPatients ?? this.admittedPatients,
      consultationsToday: consultationsToday ?? this.consultationsToday,
      completedConsultations: completedConsultations ?? this.completedConsultations,
      bedOccupancyRate: bedOccupancyRate ?? this.bedOccupancyRate,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      urgentAlerts: urgentAlerts ?? this.urgentAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminDashboardProvider = StateNotifierProvider<AdminDashboardNotifier, DashboardState>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return AdminDashboardNotifier(repo);
});

class AdminDashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  AdminDashboardNotifier(this._repository) : super(DashboardState(isLoading: true)) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.getDashboardData();
      state = DashboardState(
        totalPatients: data.totalPatients,
        newPatientsToday: data.newPatientsToday,
        admittedPatients: data.admittedPatients,
        consultationsToday: data.consultationsToday,
        completedConsultations: data.completedConsultations,
        bedOccupancyRate: data.bedOccupancyRate,
        upcomingAppointments: data.upcomingAppointments,
        urgentAlerts: data.urgentAlerts,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement dashboard', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
