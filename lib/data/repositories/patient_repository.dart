// 📁 lib/data/repositories/patient_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/patient_model.dart';

class PatientRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère tous les patients (Admin Hôpital)
  Future<List<PatientModel>> getAllPatients() async {
    return execute(() async {
      final response = await client
          .from('patients')
          .select('*')
          .order('full_name', ascending: true);
      return response.map((json) => PatientModel.fromJson(json)).toList();
    }, operationName: 'getAllPatients');
  }

  /// Récupère un patient par son ID
  Future<PatientModel?> getPatientById(String id) async {
    return execute(() async {
      final response = await client
          .from('patients')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      return response != null ? PatientModel.fromJson(response) : null;
    }, operationName: 'getPatientById');
  }

  /// Récupère un patient par son THIX ID (Patient)
  Future<PatientModel?> getPatientByThixId(String thixId) async {
    return execute(() async {
      final response = await client
          .from('patients')
          .select('*')
          .eq('thix_id', thixId)
          .maybeSingle();
      return response != null ? PatientModel.fromJson(response) : null;
    }, operationName: 'getPatientByThixId');
  }

  /// Récupère les patients d'un médecin (Médecin)
  Future<List<PatientModel>> getPatientsByDoctorId(String doctorId) async {
    return execute(() async {
      final response = await client
          .from('patients')
          .select('*')
          .eq('doctor_id', doctorId)
          .order('full_name', ascending: true);
      return response.map((json) => PatientModel.fromJson(json)).toList();
    }, operationName: 'getPatientsByDoctorId');
  }

  /// Recherche des patients par nom, email ou ID hospitalier
  Future<List<PatientModel>> searchPatients(String query) async {
    return execute(() async {
      final response = await client
          .from('patients')
          .select('*')
          .or('full_name.ilike.%$query%,email.ilike.%$query%,hospital_id.ilike.%$query%')
          .order('full_name', ascending: true);
      return response.map((json) => PatientModel.fromJson(json)).toList();
    }, operationName: 'searchPatients');
  }

  // ==================== CRUD ====================

  /// Ajoute un nouveau patient
  Future<PatientModel?> addPatient(PatientModel patient) async {
    return execute(() async {
      final response = await client
          .from('patients')
          .insert(patient.toJson())
          .select()
          .single();
      return PatientModel.fromJson(response);
    }, operationName: 'addPatient');
  }

  /// Met à jour un patient
  Future<PatientModel?> updatePatient(PatientModel patient) async {
    return execute(() async {
      final response = await client
          .from('patients')
          .update(patient.toJson())
          .eq('id', patient.id)
          .select()
          .single();
      return PatientModel.fromJson(response);
    }, operationName: 'updatePatient');
  }

  /// Supprime un patient
  Future<bool> deletePatient(String id) async {
    return execute(() async {
      await client.from('patients').delete().eq('id', id);
      return true;
    }, operationName: 'deletePatient');
  }
}
