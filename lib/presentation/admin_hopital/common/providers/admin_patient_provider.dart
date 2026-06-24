// 📁 lib/presentation/admin_hopital/common/providers/admin_patient_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/patient_model.dart';
import '../../../../data/repositories/hospital/patient_repository.dart';
import '../../../../core/utils/logger.dart';

final patientRepositoryProvider = Provider((ref) => PatientRepository());

class PatientListState {
  final List<PatientModel> patients;
  final List<PatientModel> filteredPatients;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  PatientListState({
    this.patients = const [],
    this.filteredPatients = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  PatientListState copyWith({
    List<PatientModel>? patients,
    List<PatientModel>? filteredPatients,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return PatientListState(
      patients: patients ?? this.patients,
      filteredPatients: filteredPatients ?? this.filteredPatients,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final adminPatientProvider = StateNotifierProvider<AdminPatientNotifier, PatientListState>((ref) {
  final repo = ref.watch(patientRepositoryProvider);
  return AdminPatientNotifier(repo);
});

class AdminPatientNotifier extends StateNotifier<PatientListState> {
  final PatientRepository _repository;

  AdminPatientNotifier(this._repository) : super(PatientListState(isLoading: true)) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final patients = await _repository.getAllPatients();
      state = PatientListState(
        patients: patients,
        filteredPatients: patients,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement patients', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void searchPatients(String query) {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) {
      state = state.copyWith(
        filteredPatients: state.patients,
        searchQuery: '',
      );
      return;
    }
    final filtered = state.patients.where((p) =>
      p.fullName.toLowerCase().contains(lowerQuery) ||
      p.email.toLowerCase().contains(lowerQuery) ||
      p.phoneNumber.contains(lowerQuery) ||
      p.hospitalId.contains(lowerQuery)
    ).toList();
    state = state.copyWith(
      filteredPatients: filtered,
      searchQuery: query,
    );
  }

  Future<PatientModel?> getPatientById(String id) async {
    try {
      return await _repository.getPatientById(id);
    } catch (e) {
      Logger.error('Erreur chargement patient', error: e);
      return null;
    }
  }

  Future<bool> addPatient(PatientModel patient) async {
    state = state.copyWith(isLoading: true);
    try {
      final added = await _repository.addPatient(patient);
      if (added != null) {
        final updatedList = [...state.patients, added];
        state = PatientListState(
          patients: updatedList,
          filteredPatients: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur ajout patient', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePatient(PatientModel patient) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.updatePatient(patient);
      if (updated != null) {
        final updatedList = state.patients.map((p) => p.id == updated.id ? updated : p).toList();
        state = PatientListState(
          patients: updatedList,
          filteredPatients: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur mise à jour patient', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.deletePatient(id);
      if (success) {
        final updatedList = state.patients.where((p) => p.id != id).toList();
        state = PatientListState(
          patients: updatedList,
          filteredPatients: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur suppression patient', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
