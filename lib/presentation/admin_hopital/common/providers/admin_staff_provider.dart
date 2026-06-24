// 📁 lib/presentation/admin_hopital/common/providers/admin_staff_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/staff_model.dart';
import '../../../../data/repositories/hospital/staff_repository.dart';
import '../../../../core/utils/logger.dart';

final staffRepositoryProvider = Provider((ref) => StaffRepository());

class StaffState {
  final List<StaffModel> staff;
  final List<StaffModel> filteredStaff;
  final bool isLoading;
  final String? error;

  StaffState({
    this.staff = const [],
    this.filteredStaff = const [],
    this.isLoading = false,
    this.error,
  });

  StaffState copyWith({
    List<StaffModel>? staff,
    List<StaffModel>? filteredStaff,
    bool? isLoading,
    String? error,
  }) {
    return StaffState(
      staff: staff ?? this.staff,
      filteredStaff: filteredStaff ?? this.filteredStaff,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminStaffProvider = StateNotifierProvider<AdminStaffNotifier, StaffState>((ref) {
  final repo = ref.watch(staffRepositoryProvider);
  return AdminStaffNotifier(repo);
});

class AdminStaffNotifier extends StateNotifier<StaffState> {
  final StaffRepository _repository;

  AdminStaffNotifier(this._repository) : super(StaffState(isLoading: true)) {
    loadStaff();
  }

  Future<void> loadStaff() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final staff = await _repository.getAllStaff();
      state = StaffState(
        staff: staff,
        filteredStaff: staff,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement personnel', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addStaff(StaffModel staff) async {
    state = state.copyWith(isLoading: true);
    try {
      final added = await _repository.addStaff(staff);
      if (added != null) {
        final updatedList = [...state.staff, added];
        state = StaffState(
          staff: updatedList,
          filteredStaff: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur ajout personnel', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateStaff(StaffModel staff) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.updateStaff(staff);
      if (updated != null) {
        final updatedList = state.staff.map((s) => s.id == updated.id ? updated : s).toList();
        state = StaffState(
          staff: updatedList,
          filteredStaff: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur mise à jour personnel', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
