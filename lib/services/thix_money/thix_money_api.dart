import 'package:supabase_flutter/supabase_flutter.dart';

class ThixMoneyApi {
  static const String functionBase = 'thix-money';
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<dynamic> invoke(String functionName, {Map<String, dynamic>? body}) async {
    try {
      final response = await _supabase.functions.invoke(
        '$functionBase/$functionName',
        body: body ?? {},
      );
      if (response.hasError) {
        throw Exception('Erreur API: ${response.error}');
      }
      return response.data;
    } catch (e) {
      throw Exception('ThixMoneyApi error: $e');
    }
  }
}
