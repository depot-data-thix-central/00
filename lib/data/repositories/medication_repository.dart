// 📁 lib/data/repositories/medication_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/medication_model.dart';

class MedicationRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère tous les médicaments
  Future<List<MedicationModel>> getAllMedications() async {
    return execute(() async {
      final response = await client
          .from('medications')
          .select('*')
          .order('name', ascending: true);
      return response.map((json) => MedicationModel.fromJson(json)).toList();
    }, operationName: 'getAllMedications');
  }

  /// Récupère un médicament par ID
  Future<MedicationModel?> getMedicationById(String id) async {
    return execute(() async {
      final response = await client
          .from('medications')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      return response != null ? MedicationModel.fromJson(response) : null;
    }, operationName: 'getMedicationById');
  }

  // ==================== CRUD ====================

  /// Met à jour le stock d'un médicament
  Future<bool> updateStock(String medicationId, int newQuantity) async {
    return execute(() async {
      await client
          .from('medications')
          .update({'quantity': newQuantity})
          .eq('id', medicationId);
      return true;
    }, operationName: 'updateStock');
  }

  /// Ajoute un médicament
  Future<MedicationModel?> addMedication(MedicationModel medication) async {
    return execute(() async {
      final response = await client
          .from('medications')
          .insert(medication.toJson())
          .select()
          .single();
      return MedicationModel.fromJson(response);
    }, operationName: 'addMedication');
  }

  /// Met à jour un médicament
  Future<MedicationModel?> updateMedication(MedicationModel medication) async {
    return execute(() async {
      final response = await client
          .from('medications')
          .update(medication.toJson())
          .eq('id', medication.id)
          .select()
          .single();
      return MedicationModel.fromJson(response);
    }, operationName: 'updateMedication');
  }
}
