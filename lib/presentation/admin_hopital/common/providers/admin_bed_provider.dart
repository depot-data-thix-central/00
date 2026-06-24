// 📁 lib/presentation/admin_hopital/common/providers/admin_bed_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/bed_model.dart';
import '../../../../data/repositories/hospital/bed_repository.dart';
import '../../../../core/utils/logger.dart';

final bedRepositoryProvider = Provider((ref) => BedRepository());

class BedState {
  final List<BedModel> beds;
  final List<BedModel> filteredBeds;
  final bool isLoading;
  final String? error;

  BedState({
    this.beds = const [],
    this.filteredBeds = const [],
    this.isLoading = false,
    this.error,
  });

  BedState copyWith({
    List<BedModel>? beds,
    List<BedModel>? filteredBeds,
    bool? isLoading,
    String? error,
  }) {
    return BedState(
      beds: beds ?? this.beds,
      filteredBeds: filteredBeds ?? this.filteredBeds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminBedProvider = StateNotifierProvider<AdminBedNotifier, BedState>((ref) {
  final repo = ref.watch(bedRepositoryProvider);
  return AdminBedNotifier(repo);
});

class AdminBedNotifier extends StateNotifier<BedState> {
  final BedRepository _repository;

  AdminBedNotifier(this._repository) : super(BedState(isLoading: true)) {
    loadBeds();
  }

  Future<void> loadBeds({String? service}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final beds = await _repository.getBeds(service: service);
      state = BedState(
        beds: beds,
        filteredBeds: beds,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement lits', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateBedStatus(String bedId, String status) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.updateBedStatus(bedId, status);
      if (success) {
        final updatedList = state.beds.map((b) {
          if (b.id == bedId) return b.copyWith(status: status);
          return b;
        }).toList();
        state = BedState(
          beds: updatedList,
          filteredBeds: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur mise à jour lit', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> assignPatientToBed(String bedId, String patientId) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.assignPatientToBed(bedId, patientId);
      if (success) {
        final updatedList = state.beds.map((b) {
          if (b.id == bedId) return b.copyWith(patientId: patientId, status: 'occupied');
          return b;
        }).toList();
        state = BedState(
          beds: updatedList,
          filteredBeds: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur assignation patient au lit', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
