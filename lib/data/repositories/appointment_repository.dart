// 📁 lib/data/repositories/appointment_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/appointment_model.dart';

class AppointmentRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère les rendez-vous (optionnellement par date)
  Future<List<AppointmentModel>> getAppointments({DateTime? date}) async {
    return execute(() async {
      var query = client.from('appointments').select('*');
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        query = query
            .gte('date', startOfDay.toIso8601String())
            .lte('date', endOfDay.toIso8601String());
      }
      final response = await query.order('date', ascending: true);
      return response.map((json) => AppointmentModel.fromJson(json)).toList();
    }, operationName: 'getAppointments');
  }

  /// Récupère les rendez-vous d'un patient
  Future<List<AppointmentModel>> getAppointmentsByPatient(String patientId) async {
    return execute(() async {
      final response = await client
          .from('appointments')
          .select('*')
          .eq('patient_id', patientId)
          .order('date', ascending: false);
      return response.map((json) => AppointmentModel.fromJson(json)).toList();
    }, operationName: 'getAppointmentsByPatient');
  }

  /// Récupère les rendez-vous d'un médecin
  Future<List<AppointmentModel>> getAppointmentsByDoctor(String doctorId) async {
    return execute(() async {
      final response = await client
          .from('appointments')
          .select('*')
          .eq('doctor_id', doctorId)
          .order('date', ascending: true);
      return response.map((json) => AppointmentModel.fromJson(json)).toList();
    }, operationName: 'getAppointmentsByDoctor');
  }

  // ==================== CRUD ====================

  /// Crée un rendez-vous
  Future<AppointmentModel?> createAppointment(AppointmentModel appointment) async {
    return execute(() async {
      final response = await client
          .from('appointments')
          .insert(appointment.toJson())
          .select()
          .single();
      return AppointmentModel.fromJson(response);
    }, operationName: 'createAppointment');
  }

  /// Met à jour un rendez-vous
  Future<AppointmentModel?> updateAppointment(AppointmentModel appointment) async {
    return execute(() async {
      final response = await client
          .from('appointments')
          .update(appointment.toJson())
          .eq('id', appointment.id)
          .select()
          .single();
      return AppointmentModel.fromJson(response);
    }, operationName: 'updateAppointment');
  }

  /// Annule un rendez-vous
  Future<bool> cancelAppointment(String id) async {
    return execute(() async {
      await client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', id);
      return true;
    }, operationName: 'cancelAppointment');
  }
}
