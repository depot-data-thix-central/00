// 📁 lib/services/storage_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import '../data/repositories/base_repository.dart';

class StorageService extends BaseRepository {
  // ==================== UPLOAD ====================

  /// Upload d'un fichier vers un bucket Supabase
  /// Retourne l'URL publique du fichier
  Future<String?> uploadFile({
    required File file,
    required String bucketName, // ex: 'documents', 'prescriptions', 'profiles'
    required String folder, // ex: 'patient_123/consultations'
    String? fileName,
  }) async {
    return execute(() async {
      final originalName = basename(file.path);
      final uniqueName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_$originalName';
      final path = '$folder/$uniqueName';

      await client.storage
          .from(bucketName)
          .upload(path, file, fileOptions: const FileOptions(cacheControl: '3600'));

      // Retourner l'URL publique
      final publicUrl = client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    }, operationName: 'uploadFile');
  }

  /// Upload d'un fichier depuis des bytes (ex: signature, PDF généré)
  Future<String?> uploadBytes({
    required List<int> bytes,
    required String bucketName,
    required String folder,
    required String fileName,
  }) async {
    return execute(() async {
      final path = '$folder/$fileName';

      await client.storage
          .from(bucketName)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(cacheControl: '3600'));

      final publicUrl = client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    }, operationName: 'uploadBytes');
  }

  // ==================== TÉLÉCHARGEMENT ====================

  /// Télécharge un fichier depuis Supabase Storage
  Future<List<int>?> downloadFile({
    required String bucketName,
    required String path,
  }) async {
    return execute(() async {
      final response = await client.storage.from(bucketName).download(path);
      return response;
    }, operationName: 'downloadFile');
  }

  /// Récupère l'URL publique d'un fichier
  String getPublicUrl({
    required String bucketName,
    required String path,
  }) {
    return client.storage.from(bucketName).getPublicUrl(path);
  }

  // ==================== SUPPRESSION ====================

  /// Supprime un fichier
  Future<void> deleteFile({
    required String bucketName,
    required String path,
  }) async {
    return execute(() async {
      await client.storage.from(bucketName).remove([path]);
    }, operationName: 'deleteFile');
  }

  /// Supprime plusieurs fichiers
  Future<void> deleteFiles({
    required String bucketName,
    required List<String> paths,
  }) async {
    return execute(() async {
      await client.storage.from(bucketName).remove(paths);
    }, operationName: 'deleteFiles');
  }

  // ==================== LISTE ====================

  /// Liste les fichiers dans un dossier
  Future<List<Map<String, dynamic>>> listFiles({
    required String bucketName,
    required String folder,
  }) async {
    return execute(() async {
      final response = await client.storage.from(bucketName).list(path: folder);
      return response;
    }, operationName: 'listFiles');
  }
}
