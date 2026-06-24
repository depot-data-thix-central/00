import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'supabase_edge_token';

  // Récupérer le token (le générer si absent ou expiré)
  static Future<String> getToken() async {
    final stored = await _storage.read(key: _tokenKey);
    if (stored != null && !_isExpired(stored)) return stored;
    return await _refreshToken();
  }

  static Future<String> _refreshToken() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    if (session == null) throw Exception('Non authentifié');
    // Appel à la Edge Function /generate-token
    final response = await supabase.functions.invoke('generate-token', body: {
      'user_id': session.user.id,
    });
    final token = response.data['token'] as String;
    await _storage.write(key: _tokenKey, value: token);
    return token;
  }

  static bool _isExpired(String token) {
    // Vérification simple avec JwtDecoder
    try {
      final payload = JwtDecoder.decode(token);
      final exp = payload['exp'] as int;
      return DateTime.now().millisecondsSinceEpoch > exp * 1000;
    } catch (_) {
      return true;
    }
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
