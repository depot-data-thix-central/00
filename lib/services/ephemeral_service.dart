// lib/services/ephemeral_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/ephemeral_models.dart';

class EphemeralService {
  final SupabaseClient _supabase;

  EphemeralService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<EphemeralSettings?> getSettings() async {
    try {
      final response = await _supabase
          .from('ephemeral_settings')
          .select('*')
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (response == null) {
        return EphemeralSettings(
          id: '',
          userId: currentUserId,
          defaultDuration: 30,
          notifyScreenshot: true,
          isEnabled: false,
        );
      }
      return EphemeralSettings.fromJson(response);
    } catch (e) {
      debugPrint('Error getting settings: $e');
      return null;
    }
  }

  Future<void> updateSettings(EphemeralSettings settings) async {
    try {
      final existing = await _supabase
          .from('ephemeral_settings')
          .select('id')
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('ephemeral_settings').insert(settings.toJson());
      } else {
        await _supabase
            .from('ephemeral_settings')
            .update(settings.toJson())
            .eq('user_id', currentUserId);
      }
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }

  Future<List<ScreenshotAlert>> getScreenshotAlerts() async {
    try {
      final response = await _supabase
          .from('screenshot_alerts')
          .select('*, users:captured_by(display_name)')
          .eq('user_id', currentUserId)
          .order('captured_at', ascending: false)
          .limit(20);

      return (response as List).map((e) => ScreenshotAlert.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting alerts: $e');
      return [];
    }
  }

  Future<void> reportScreenshot(String messageId) async {
    await _supabase.from('screenshot_alerts').insert({
      'message_id': messageId,
      'user_id': currentUserId,
      'captured_by': currentUserId,
      'captured_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteExpiredMessages() async {
    await _supabase
        .from('messages')
        .delete()
        .eq('is_ephemeral', true)
        .lt('expires_at', DateTime.now().toIso8601String());
  }
}
