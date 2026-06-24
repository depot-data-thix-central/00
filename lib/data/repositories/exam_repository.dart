// 📁 lib/data/repositories/exam_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/exam_model.dart';

class ExamRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère tous les examens
  Future<List<ExamModel>> getAllExams() async {
    return execute(() async {
      final response = await client
          .from('exams')
          .select('*')
          .order('date', ascending: false);
      return response.map((json) => ExamModel.fromJson(json)).toList();
    }, operationName: 'getAllExams');
  }

  /// Récupère les examens d'un patient
  Future<List<ExamModel>> getExamsByPatient(String patientId) async {
    return execute(() async {
      final response = await client
          .from('exams')
          .select('*')
          .eq('patient_id', patientId)
          .order('date', ascending: false);
      return response.map((json) => ExamModel.fromJson(json)).toList();
    }, operationName: 'getExamsByPatient');
  }

  // ==================== CRUD ====================

  /// Ajoute un examen
  Future<ExamModel?> addExam(ExamModel exam) async {
    return execute(() async {
      final response = await client
          .from('exams')
          .insert(exam.toJson())
          .select()
          .single();
      return ExamModel.fromJson(response);
    }, operationName: 'addExam');
  }

  /// Ajoute un résultat d'examen
  Future<bool> addResult(String examId, String result) async {
    return execute(() async {
      await client
          .from('exams')
          .update({
            'result': result,
            'status': 'completed',
          })
          .eq('id', examId);
      return true;
    }, operationName: 'addResult');
  }

  /// Met à jour un examen
  Future<ExamModel?> updateExam(ExamModel exam) async {
    return execute(() async {
      final response = await client
          .from('exams')
          .update(exam.toJson())
          .eq('id', exam.id)
          .select()
          .single();
      return ExamModel.fromJson(response);
    }, operationName: 'updateExam');
  }
}
