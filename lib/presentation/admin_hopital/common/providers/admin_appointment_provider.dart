// 📁 lib/presentation/admin_hopital/common/providers/admin_appointment_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/appointment_model.dart';
import '../../../../data/repositories/hospital/appointment_repository.dart';
import '../../../../core/utils/logger.dart';

final appointmentRepositoryProvider = Provider((ref) => AppointmentRepository());

class AppointmentState {
  final List<AppointmentModel> appointments;
  final List<AppointmentModel> filteredAppointments;
  final bool isLoading;
  final String? error;

  AppointmentState({
    this.appointments = const [],
    this.filteredAppointments = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentState copyWith({
    List<AppointmentModel>? appointments,
    List<AppointmentModel>? filteredAppointments,
    bool? isLoading,
    String? error,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      filteredAppointments: filteredAppointments ?? this.filteredAppointments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminAppointmentProvider = StateNotifierProvider<AdminAppointmentNotifier, AppointmentState>((ref) {
  final repo = ref.watch(appointmentRepositoryProvider);
  return AdminAppointmentNotifier(repo);
});

class AdminAppointmentNotifier extends StateNotifier<AppointmentState> {
  final AppointmentRepository _repository;

  AdminAppointmentNotifier(this._repository) : super(AppointmentState(isLoading: true)) {
    loadAppointments();
  }

  Future<void> loadAppointments({DateTime? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appointments = await _repository.getAppointments(date: date);
      state = AppointmentState(
        appointments: appointments,
        filteredAppointments: appointments,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement rendez-vous', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createAppointment(AppointmentModel appointment) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _repository.createAppointment(appointment);
      if (created != null) {
        final updatedList = [...state.appointments, created];
        state = AppointmentState(
          appointments: updatedList,
          filteredAppointments: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur création rendez-vous', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAppointment(AppointmentModel appointment) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.updateAppointment(appointment);
      if (updated != null) {
        final updatedList = state.appointments.map((a) => a.id == updated.id ? updated : a).toList();
        state = AppointmentState(
          appointments: updatedList,
          filteredAppointments: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur mise à jour rendez-vous', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelAppointment(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.cancelAppointment(id);
      if (success) {
        final updatedList = state.appointments.where((a) => a.id != id).toList();
        state = AppointmentState(
          appointments: updatedList,
          filteredAppointments: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur annulation rendez-vous', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
