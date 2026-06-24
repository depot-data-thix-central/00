// 📁 lib/data/repositories/base_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';

/// Repository de base qui fournit le client Supabase et une gestion d'erreurs unifiée
abstract class BaseRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Exécute une requête avec gestion d'erreur centralisée
  Future<T> execute<T>(Future<T> Function() operation, {String? operationName}) async {
    try {
      return await operation();
    } catch (e, st) {
      Logger.error(
        'Erreur ${operationName ?? 'repository'}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Retourne le client Supabase pour les repositories enfants
  SupabaseClient get client => _client;
}
