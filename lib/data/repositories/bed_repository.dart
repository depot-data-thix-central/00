// 📁 lib/data/repositories/bed_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/bed_model.dart';

class BedRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère tous les lits (optionnellement par service)
  Future<List<BedModel>> getBeds({String? service}) async {
    return execute(() async {
      var query = client.from('beds').select('*');
      if (service != null && service != 'all') {
        query = query.eq('service', service);
      }
      final response = await query.order('number', ascending: true);
      return response.map((json) => BedModel.fromJson(json)).toList();
    }, operationName: 'getBeds');
  }

  /// Récupère un lit par son ID
  Future<BedModel?> getBedById(String id) async {
    return execute(() async {
      final response = await client
          .from('beds')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      return response != null ? BedModel.fromJson(response) : null;
    }, operationName: 'getBedById');
  }

  // ==================== CRUD ====================

  /// Met à jour le statut d'un lit
  Future<bool> updateBedStatus(String bedId, String status) async {
    return execute(() async {
      await client
          .from('beds')
          .update({'status': status})
          .eq('id', bedId);
      return true;
    }, operationName: 'updateBedStatus');
  }

  /// Assigne un patient à un lit
  Future<bool> assignPatientToBed(String bedId, String patientId) async {
    return execute(() async {
      // Récupérer le patient
      final patientRes = await client
          .from('patients')
          .select('full_name')
          .eq('id', patientId)
          .maybeSingle();
      final patientName = patientRes?['full_name'] ?? 'Patient';

      await client
          .from('beds')
          .update({
            'status': 'occupied',
            'patient_id': patientId,
            'patient_name': patientName,
          })
          .eq('id', bedId);
      return true;
    }, operationName: 'assignPatientToBed');
  }

  /// Libère un lit (le met en nettoyage)
  Future<bool> freeBed(String bedId) async {
    return execute(() async {
      await client
          .from('beds')
          .update({
            'status': 'cleaning',
            'patient_id': null,
            'patient_name': null,
          })
          .eq('id', bedId);
      return true;
    }, operationName: 'freeBed');
  }
}
