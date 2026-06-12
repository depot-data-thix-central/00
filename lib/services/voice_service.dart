// lib/services/voice_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class VoiceService {
  final SupabaseClient _supabase;

  VoiceService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<String?> uploadAudio(File audioFile) async {
    try {
      final bytes = await audioFile.readAsBytes();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = 'voice_messages/$currentUserId/$fileName';
      
      await _supabase.storage.from('chat').uploadBinary(storagePath, bytes);
      return _supabase.storage.from('chat').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      return null;
    }
  }

  Future<String?> transcribeAudio(String audioUrl) async {
    try {
      // Simulation de transcription
      await Future.delayed(const Duration(seconds: 2));
      return "Ceci est une transcription automatique du message vocal.";
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      return null;
    }
  }

  Future<void> saveTranscript(String messageId, String transcript) async {
    try {
      await _supabase
          .from('messages')
          .update({'audio_transcript': transcript})
          .eq('id', messageId);
    } catch (e) {
      debugPrint('Error saving transcript: $e');
    }
  }
}
