// lib/presentation/chat/core/chat_repository.dart
// [PARTIE] Repository : communication avec Supabase + gestion confidentiel/éphémère

import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_models.dart';
import 'chat_constants.dart';
import 'chat_utils.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer les conversations de l'utilisateur connecté
  Future<List<Conversation>> fetchConversations(String userId) async {
    final response = await _supabase
        .from(ChatConstants.tableConversations)
        .select('*, participants!inner(user_id)')
        .eq('participants.user_id', userId)
        .order('last_message_time', ascending: false);

    return response.map<Conversation>((json) => Conversation.fromJson(json)).toList();
  }

  // Récupérer les messages d'une conversation (pagination)
  Future<List<Message>> fetchMessages(String conversationId, {int limit = 50}) async {
    final response = await _supabase
        .from(ChatConstants.tableMessages)
        .select()
        .eq('conversation_id', conversationId)
        .order('sent_at', ascending: false)
        .limit(limit);

    return response.map<Message>((json) => Message.fromJson(json)).toList();
  }

  // Envoyer un message (générique)
  Future<Message> sendMessage(Message message) async {
    final response = await _supabase
        .from(ChatConstants.tableMessages)
        .insert(message.toJson())
        .select()
        .single();

    final sentMessage = Message.fromJson(response);

    // Gestion spécifique éphémère
    if (message.type == ChatConstants.messageTypeEphemeral && message.metadata != null) {
      await _supabase.from(ChatConstants.tableEphemeralMessages).insert({
        'message_id': sentMessage.id,
        'duration_seconds': message.metadata![ChatConstants.metadataKeyDuration],
        'opened_at': null,
      });
    }

    // Gestion spécifique confidentiel
    if (message.type == ChatConstants.messageTypeConfidential && message.metadata != null) {
      await _supabase.from(ChatConstants.tableConfidentialMessages).insert({
        'message_id': sentMessage.id,
        'code_hash': message.metadata![ChatConstants.metadataKeyCodeHash],
        'is_biometric': message.metadata![ChatConstants.metadataKeyIsBiometric] ?? false,
        'is_opened': false,
      });
    }

    return sentMessage;
  }

  // Vérifier le code d'un message confidentiel et le marquer comme ouvert
  Future<bool> verifyConfidentialCode(String messageId, String enteredCode) async {
    final response = await _supabase
        .from(ChatConstants.tableConfidentialMessages)
        .select('code_hash, is_biometric')
        .eq('message_id', messageId)
        .single();

    final storedHash = response['code_hash'];
    final isBiometric = response['is_biometric'] as bool;

    bool isValid = false;
    if (isBiometric) {
      isValid = await _authenticateWithBiometrics();
    } else {
      isValid = ChatUtils.hashCode(enteredCode) == storedHash;
    }

    if (isValid) {
      await _supabase
          .from(ChatConstants.tableConfidentialMessages)
          .update({'is_opened': true})
          .eq('message_id', messageId);
    }
    return isValid;
  }

  Future<bool> _authenticateWithBiometrics() async {
    // Implémentez avec package local_auth
    // Pour l'exemple on retourne true (à remplacer)
    return true;
  }

  // Marquer un message comme lu
  Future<void> markAsRead(String messageId, String userId) async {
    await _supabase.from(ChatConstants.tableReadReceipts).upsert({
      'message_id': messageId,
      'user_id': userId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }

  // Ajouter une réaction
  Future<void> addReaction(String messageId, String reaction, String userId) async {
    final message = await _supabase
        .from(ChatConstants.tableMessages)
        .select('reactions')
        .eq('id', messageId)
        .single();

    List<String> reactions = List<String>.from(message['reactions'] ?? []);
    if (!reactions.contains(reaction)) {
      reactions.add(reaction);
      await _supabase
          .from(ChatConstants.tableMessages)
          .update({'reactions': reactions})
          .eq('id', messageId);
    }
  }

  // Supprimer un message (soft delete global ou local)
  Future<void> deleteMessage(String messageId, String userId, {bool forEveryone = false}) async {
    if (forEveryone) {
      await _supabase
          .from(ChatConstants.tableMessages)
          .update({'is_deleted': true, 'content': 'Message supprimé'})
          .eq('id', messageId);
    } else {
      await _supabase.from(ChatConstants.tableDeletedMessages).insert({
        'message_id': messageId,
        'user_id': userId,
      });
    }
  }

  // Mettre à jour la présence
  Future<void> updatePresence(String userId, String status) async {
    await _supabase.from('users').update({
      'status': status,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Stream en temps réel pour les nouveaux messages
  Stream<Message> listenForNewMessages(String conversationId) {
    return _supabase
        .from(ChatConstants.tableMessages)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('sent_at', ascending: false)
        .limit(1)
        .map((event) => Message.fromJson(event.first));
  }

  // Récupérer les stories (exemple : contacts avec stories actives)
  Future<List<Story>> fetchStories(String userId) async {
    // À adapter selon votre logique métier
    final response = await _supabase
        .from('stories')
        .select('id, user_id, users(name, avatar_url)')
        .eq('expires_at', isNot: null)
        .gt('expires_at', DateTime.now().toIso8601String());
    // Transformation en Story (simplifié)
    return response.map<Story>((json) => Story(
      id: json['id'],
      name: json['users']['name'],
      avatarUrl: json['users']['avatar_url'],
      hasNewStory: true,
    )).toList();
  }

  // Récupérer les stats du chat
  Future<ChatStats> fetchChatStats(String userId) async {
    // Exemples de compteurs (à remplacer par vraies requêtes)
    return const ChatStats(
      onlineCount: 142,
      newMessagesCount: 38,
      activeMeetingsCount: 12,
      securityAlertsCount: 7,
    );
  }
}
