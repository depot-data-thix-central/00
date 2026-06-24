// 📁 lib/presentation/admin_hopital/common/providers/admin_medication_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/medication_model.dart';
import '../../../../data/repositories/hospital/medication_repository.dart';
import '../../../../core/utils/logger.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

class MedicationState {
  final List<MedicationModel> medications;
  final List<MedicationModel> filteredMedications;
  final bool isLoading;
  final String? error;

  MedicationState({
    this.medications = const [],
    this.filteredMedications = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<MedicationModel>? medications,
    List<MedicationModel>? filteredMedications,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      filteredMedications: filteredMedications ?? this.filteredMedications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminMedicationProvider = StateNotifierProvider<AdminMedicationNotifier, MedicationState>((ref) {
  final repo = ref.watch(medicationRepositoryProvider);
  return AdminMedicationNotifier(repo);
});

class AdminMedicationNotifier extends StateNotifier<MedicationState> {
  final MedicationRepository _repository;

  AdminMedicationNotifier(this._repository) : super(MedicationState(isLoading: true)) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final medications = await _repository.getAllMedications();
      state = MedicationState(
        medications: medications,
        filteredMedications: medications,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement médicaments', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateStock(String medicationId, int newQuantity) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.updateStock(medicationId, newQuantity);
      if (success) {
        final updatedList = state.medications.map((m) {
          if (m.id == medicationId) return m.copyWith(stock: newQuantity);
          return m;
        }).toList();
        state = MedicationState(
          medications: updatedList,
          filteredMedications: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur mise à jour stock', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
