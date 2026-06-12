// lib/services/scheduled_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/scheduled_models.dart';

class ScheduledService {
  final SupabaseClient _supabase;

  ScheduledService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<List<ScheduledMessage>> getScheduledMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('scheduled_messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .eq('status', 'pending')
          .order('scheduled_at', ascending: true);

      return (response as List).map((e) => ScheduledMessage.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting scheduled messages: $e');
      return [];
    }
  }

  Future<void> scheduleMessage({
    required String conversationId,
    required String content,
    required DateTime scheduledAt,
    bool isRecurring = false,
    String? recurringPattern,
  }) async {
    await _supabase.from('scheduled_messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'content': content,
      'scheduled_at': scheduledAt.toIso8601String(),
      'is_recurring': isRecurring,
      'recurring_pattern': recurringPattern,
      'status': 'pending',
    });
  }

  Future<void> cancelScheduledMessage(String id) async {
    await _supabase
        .from('scheduled_messages')
        .update({'status': 'cancelled'})
        .eq('id', id);
  }

  Future<void> processScheduledMessages() async {
    final now = DateTime.now().toIso8601String();
    final messages = await _supabase
        .from('scheduled_messages')
        .select('*')
        .eq('status', 'pending')
        .lte('scheduled_at', now);

    for (var msg in messages as List) {
      await _supabase.from('messages').insert({
        'conversation_id': msg['conversation_id'],
        'sender_id': msg['sender_id'],
        'content': msg['content'],
        'created_at': now,
      });
      
      if (msg['is_recurring'] == true) {
        final nextDate = _getNextDate(
          DateTime.parse(msg['scheduled_at']),
          msg['recurring_pattern'],
        );
        await _supabase.from('scheduled_messages').update({
          'scheduled_at': nextDate.toIso8601String(),
        }).eq('id', msg['id']);
      } else {
        await _supabase
            .from('scheduled_messages')
            .update({'status': 'sent'})
            .eq('id', msg['id']);
      }
    }
  }

  DateTime _getNextDate(DateTime current, String pattern) {
    switch (pattern) {
      case 'daily': return current.add(const Duration(days: 1));
      case 'weekly': return current.add(const Duration(days: 7));
      case 'monthly': return DateTime(current.year, current.month + 1, current.day);
      default: return current;
    }
  }
}
