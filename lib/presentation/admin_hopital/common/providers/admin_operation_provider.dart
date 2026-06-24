// 📁 lib/presentation/admin_hopital/common/providers/admin_operation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/operation_model.dart';
import '../../../../data/repositories/hospital/operation_repository.dart';
import '../../../../core/utils/logger.dart';

final operationRepositoryProvider = Provider((ref) => OperationRepository());

class OperationState {
  final List<OperationModel> operations;
  final bool isLoading;
  final String? error;

  OperationState({
    this.operations = const [],
    this.isLoading = false,
    this.error,
  });

  OperationState copyWith({
    List<OperationModel>? operations,
    bool? isLoading,
    String? error,
  }) {
    return OperationState(
      operations: operations ?? this.operations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminOperationProvider = StateNotifierProvider<AdminOperationNotifier, OperationState>((ref) {
  final repo = ref.watch(operationRepositoryProvider);
  return AdminOperationNotifier(repo);
});

class AdminOperationNotifier extends StateNotifier<OperationState> {
  final OperationRepository _repository;

  AdminOperationNotifier(this._repository) : super(OperationState(isLoading: true)) {
    loadOperations();
  }

  Future<void> loadOperations({DateTime? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final operations = await _repository.getOperations(date: date);
      state = OperationState(
        operations: operations,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement interventions', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> scheduleOperation(OperationModel operation) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _repository.scheduleOperation(operation);
      if (created != null) {
        final updatedList = [...state.operations, created];
        state = OperationState(
          operations: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur planification intervention', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> completeOperation(String operationId, String report) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.completeOperation(operationId, report);
      if (success) {
        final updatedList = state.operations.map((o) {
          if (o.id == operationId) return o.copyWith(status: 'completed', report: report);
          return o;
        }).toList();
        state = OperationState(
          operations: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur finalisation intervention', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
