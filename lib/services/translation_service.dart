// lib/services/translation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  final SupabaseClient _supabase;
  static const String _translationApiUrl = 'https://api.mymemory.translated.net/get';

  TranslationService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      final response = await _supabase
          .from('translation_settings')
          .select('*')
          .eq('user_id', currentUserId)
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting settings: $e');
      return null;
    }
  }

  Future<void> saveUserSettings({
    required String targetLanguage,
    required bool autoTranslate,
    required bool autoDetect,
    required bool translateOutgoing,
  }) async {
    try {
      final existing = await _supabase
          .from('translation_settings')
          .select('id')
          .eq('user_id', currentUserId)
          .maybeSingle();

      final data = {
        'target_language': targetLanguage,
        'auto_translate': autoTranslate,
        'auto_detect': autoDetect,
        'translate_outgoing': translateOutgoing,
      };

      if (existing == null) {
        await _supabase.from('translation_settings').insert({
          'user_id': currentUserId,
          ...data,
        });
      } else {
        await _supabase
            .from('translation_settings')
            .update(data)
            .eq('user_id', currentUserId);
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<String?> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (text.trim().isEmpty) return null;

    try {
      final url = Uri.parse(
        '$_translationApiUrl?q=${Uri.encodeComponent(text)}&langpair=$sourceLang|$targetLang'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['responseData']['translatedText'];
        return translatedText
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .replaceAll('&amp;', '&');
      }
      return null;
    } catch (e) {
      debugPrint('Translation API error: $e');
      return null;
    }
  }

  Future<String?> detectLanguage(String text) async {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'ar';
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) return 'zh';
    if (RegExp(r'[\u3040-\u309F\u30A0-\u30FF]').hasMatch(text)) return 'ja';
    if (RegExp(r'[\uAC00-\uD7AF]').hasMatch(text)) return 'ko';
    
    if (RegExp(r'\b(le|la|les|un|une|de|du|des|et|est|sont|pour|avec|par|dans|sur|ce|cette|ces|mon|ton|son|notre|votre|leur)\b', caseSensitive: false).hasMatch(text)) {
      return 'fr';
    }
    
    if (RegExp(r'\b(the|a|an|and|or|of|to|in|for|with|on|at|by|is|are|was|were|be|been|have|has|had|do|does|did|but|so|if|then|else|when|where|which|that|this|these|those|it|he|she|they|we|you|me|him|her|us|them)\b', caseSensitive: false).hasMatch(text)) {
      return 'en';
    }
    
    return 'fr';
  }
}
