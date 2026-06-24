// 📁 lib/presentation/admin_hopital/common/providers/admin_exam_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/exam_model.dart';
import '../../../../data/repositories/hospital/exam_repository.dart';
import '../../../../core/utils/logger.dart';

final examRepositoryProvider = Provider((ref) => ExamRepository());

class ExamState {
  final List<ExamModel> exams;
  final List<ExamModel> filteredExams;
  final bool isLoading;
  final String? error;

  ExamState({
    this.exams = const [],
    this.filteredExams = const [],
    this.isLoading = false,
    this.error,
  });

  ExamState copyWith({
    List<ExamModel>? exams,
    List<ExamModel>? filteredExams,
    bool? isLoading,
    String? error,
  }) {
    return ExamState(
      exams: exams ?? this.exams,
      filteredExams: filteredExams ?? this.filteredExams,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminExamProvider = StateNotifierProvider<AdminExamNotifier, ExamState>((ref) {
  final repo = ref.watch(examRepositoryProvider);
  return AdminExamNotifier(repo);
});

class AdminExamNotifier extends StateNotifier<ExamState> {
  final ExamRepository _repository;

  AdminExamNotifier(this._repository) : super(ExamState(isLoading: true)) {
    loadExams();
  }

  Future<void> loadExams() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final exams = await _repository.getAllExams();
      state = ExamState(
        exams: exams,
        filteredExams: exams,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement examens', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addResult(String examId, String result) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.addResult(examId, result);
      if (success) {
        final updatedList = state.exams.map((e) {
          if (e.id == examId) return e.copyWith(result: result, status: 'completed');
          return e;
        }).toList();
        state = ExamState(
          exams: updatedList,
          filteredExams: updatedList,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur ajout résultat examen', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
