// 📁 lib/data/repositories/staff_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/staff_model.dart';

class StaffRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère tout le personnel
  Future<List<StaffModel>> getAllStaff() async {
    return execute(() async {
      final response = await client
          .from('staff')
          .select('*')
          .order('full_name', ascending: true);
      return response.map((json) => StaffModel.fromJson(json)).toList();
    }, operationName: 'getAllStaff');
  }

  /// Récupère un membre du personnel par ID
  Future<StaffModel?> getStaffById(String id) async {
    return execute(() async {
      final response = await client
          .from('staff')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      return response != null ? StaffModel.fromJson(response) : null;
    }, operationName: 'getStaffById');
  }

  /// Récupère le personnel par rôle
  Future<List<StaffModel>> getStaffByRole(String role) async {
    return execute(() async {
      final response = await client
          .from('staff')
          .select('*')
          .eq('role', role)
          .order('full_name', ascending: true);
      return response.map((json) => StaffModel.fromJson(json)).toList();
    }, operationName: 'getStaffByRole');
  }

  // ==================== CRUD ====================

  /// Ajoute un membre du personnel
  Future<StaffModel?> addStaff(StaffModel staff) async {
    return execute(() async {
      final response = await client
          .from('staff')
          .insert(staff.toJson())
          .select()
          .single();
      return StaffModel.fromJson(response);
    }, operationName: 'addStaff');
  }

  /// Met à jour un membre du personnel
  Future<StaffModel?> updateStaff(StaffModel staff) async {
    return execute(() async {
      final response = await client
          .from('staff')
          .update(staff.toJson())
          .eq('id', staff.id)
          .select()
          .single();
      return StaffModel.fromJson(response);
    }, operationName: 'updateStaff');
  }

  /// Supprime un membre du personnel
  Future<bool> deleteStaff(String id) async {
    return execute(() async {
      await client.from('staff').delete().eq('id', id);
      return true;
    }, operationName: 'deleteStaff');
  }
}
