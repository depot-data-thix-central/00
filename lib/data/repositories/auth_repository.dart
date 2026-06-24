// 📁 lib/data/repositories/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/patient_model.dart';
import '../../models/thix_sante/hospital/doctor_model.dart';

class AuthRepository extends BaseRepository {
  // ==================== AUTHENTIFICATION ====================

  /// Connexion avec email et mot de passe
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    return execute(() async {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    }, operationName: 'signInWithEmail');
  }

  /// Connexion avec THIX ID (email + password)
  Future<Map<String, dynamic>> signInWithThixId(String thixId, String password) async {
    // Le THIX ID est l'email dans la plupart des cas
    return signInWithEmail(thixId, password);
  }

  /// Inscription (création de compte)
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    return execute(() async {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    }, operationName: 'signUp');
  }

  /// Déconnexion
  Future<void> signOut() async {
    return execute(() async {
      await client.auth.signOut();
    }, operationName: 'signOut');
  }

  /// Récupère l'utilisateur actuel
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Récupère le rôle de l'utilisateur actuel
  Future<String?> getUserRole() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      // Récupérer le rôle depuis la table profiles ou users
      final response = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      return response?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    return execute(() async {
      await client.auth.resetPasswordForEmail(email);
    }, operationName: 'resetPassword');
  }

  /// Met à jour le mot de passe
  Future<void> updatePassword(String newPassword) async {
    return execute(() async {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    }, operationName: 'updatePassword');
  }

  /// Vérifie si l'utilisateur est authentifié
  bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  /// Récupère le profil (patient ou médecin) de l'utilisateur connecté
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      final response = await client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }
}
