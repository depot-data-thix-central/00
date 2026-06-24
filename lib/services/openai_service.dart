// 📁 lib/services/ai/openai_service.dart

import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';

class OpenAIService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== ASSISTANT SANTÉ ====================

  /// Pose une question à l'assistant IA (via Edge Function)
  Future<String?> askAssistant({
    required String question,
    String? context,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai-assistant',
        body: {
          'message': question,
          'context': context,
        },
      );
      return response.data['reply'] as String?;
    } catch (e, st) {
      Logger.error('Erreur OpenAIService.askAssistant', error: e, stackTrace: st);
      return "Désolé, une erreur s'est produite. Veuillez réessayer.";
    }
  }

  // ==================== ANALYSE PRÉDICTIVE ====================

  /// Analyse prédictive de la santé d'un patient
  Future<Map<String, dynamic>?> getPredictiveAnalysis(String patientId) async {
    try {
      final response = await _supabase.functions.invoke(
        'predict-health',
        body: {
          'patient_id': patientId,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e, st) {
      Logger.error('Erreur OpenAIService.getPredictiveAnalysis', error: e, stackTrace: st);
      return null;
    }
  }

  // ==================== SYNTHÈSE DE DOSSIER ====================

  /// Génère un résumé de dossier patient pour le médecin
  Future<String?> generatePatientSummary(String patientId) async {
    try {
      final response = await _supabase.functions.invoke(
        'patient-summary',
        body: {
          'patient_id': patientId,
        },
      );
      return response.data['summary'] as String?;
    } catch (e, st) {
      Logger.error('Erreur OpenAIService.generatePatientSummary', error: e, stackTrace: st);
      return null;
    }
  }

  // ==================== INTERACTIONS MÉDICAMENTEUSES ====================

  /// Vérifie les interactions entre médicaments
  Future<List<String>?> checkDrugInteractions(List<String> drugNames) async {
    try {
      final response = await _supabase.functions.invoke(
        'drug-interaction',
        body: {
          'drugs': drugNames,
        },
      );
      return (response.data['interactions'] as List?)?.cast<String>();
    } catch (e, st) {
      Logger.error('Erreur OpenAIService.checkDrugInteractions', error: e, stackTrace: st);
      return null;
    }
  }

  // ==================== TRADUCTION ====================

  /// Traduit un texte médical dans une autre langue
  Future<String?> translateMedicalText({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'translate-health',
        body: {
          'text': text,
          'target_language': targetLanguage,
        },
      );
      return response.data['translated_text'] as String?;
    } catch (e, st) {
      Logger.error('Erreur OpenAIService.translateMedicalText', error: e, stackTrace: st);
      return null;
    }
  }
}
