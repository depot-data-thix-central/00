import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/admin_audit_service.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class AdminEventService {
  AdminEventService({SupabaseClient? client, AdminAuditService? audit})
      : _client = client ?? SupabaseConfig.client,
        _audit = audit ?? AdminAuditService();

  final SupabaseClient _client;
  final AdminAuditService _audit;

  static const String eventsTable = 'thix_events';
  static const String registrationsTable = 'thix_event_registrations';
  static const String eventsStatusView = 'thix_events_status';
  static const String coverBucketDefault = 'thix-events';

  // ✅ AJOUTÉ: Limite maximale par défaut
  static const int defaultLimit = 200;
  static const int maxLimit = 500;

  // ============================================================
  // LISTE DES ÉVÉNEMENTS
  // ============================================================

  Future<List<Map<String, dynamic>>> listEvents({
    int limit = defaultLimit,
    String? status,
    String? category,
    bool? isFeatured,
    bool ascending = false,
  }) async {
    try {
      debugPrint('📅 AdminEventService.listEvents: chargement des événements...');
      
      // Construire la requête
      var query = _client.from(eventsStatusView).select('*');
      
      // ✅ AJOUTÉ: Filtres optionnels
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }
      
      // Tri et limite
      final orderColumn = ascending ? 'starts_at' : 'starts_at';
      final res = await query
          .order(orderColumn, ascending: ascending)
          .limit(limit.clamp(1, maxLimit));
      
      if (res is List) {
        debugPrint('✅ AdminEventService.listEvents: ${res.length} événements chargés');
        return res.cast<Map<String, dynamic>>();
      }
      return const [];
    } catch (e) {
      debugPrint('❌ AdminEventService.listEvents failed err=$e');
      rethrow;
    }
  }

  // ============================================================
  // COMPTER LES INSCRIPTIONS
  // ============================================================

  Future<int> countRegistrations({required String eventId}) async {
    try {
      final res = await _client
          .from(registrationsTable)
          .select('id', count: CountOption.exact)
          .eq('event_id', eventId);
      
      // ✅ CORRIGÉ: Utiliser count si disponible, sinon compter la liste
      if (res.count != null) {
        return res.count ?? 0;
      }
      if (res is List) return res.length;
      return 0;
    } catch (e) {
      debugPrint('❌ AdminEventService.countRegistrations failed err=$e');
      return 0;
    }
  }

  // ✅ NOUVELLE MÉTHODE: Récupérer un événement par ID
  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      final res = await _client
          .from(eventsTable)
          .select('*')
          .eq('id', eventId)
          .maybeSingle();
      
      if (res == null) return null;
      return res as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ AdminEventService.getEventById failed err=$e');
      return null;
    }
  }

  // ✅ NOUVELLE MÉTHODE: Récupérer les événements à venir
  Future<List<Map<String, dynamic>>> getUpcomingEvents({int limit = defaultLimit}) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final res = await _client
          .from(eventsStatusView)
          .select('*')
          .eq('status', 'published')
          .gt('starts_at', now)
          .order('starts_at', ascending: true)
          .limit(limit.clamp(1, maxLimit));
      
      if (res is List) return res.cast<Map<String, dynamic>>();
      return const [];
    } catch (e) {
      debugPrint('❌ AdminEventService.getUpcomingEvents failed err=$e');
      return [];
    }
  }

  // ✅ NOUVELLE MÉTHODE: Récupérer les événements passés
  Future<List<Map<String, dynamic>>> getPastEvents({int limit = defaultLimit}) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final res = await _client
          .from(eventsStatusView)
          .select('*')
          .eq('status', 'published')
          .lt('starts_at', now)
          .order('starts_at', ascending: false)
          .limit(limit.clamp(1, maxLimit));
      
      if (res is List) return res.cast<Map<String, dynamic>>();
      return const [];
    } catch (e) {
      debugPrint('❌ AdminEventService.getPastEvents failed err=$e');
      return [];
    }
  }

  // ============================================================
  // CRÉATION / MISE À JOUR D'ÉVÉNEMENT
  // ============================================================

  Future<String> upsertEvent({
    String? id,
    required String title,
    required DateTime startsAt,
    required String place,
    String? virtualLink,
    String status = 'published',
    bool? isFeatured,
    String? quickHook,
    String? category,
    int? maxParticipants,
    bool? isFree,
    num? price,
    String? eventType,
    String? meetingLink,
    String? organizer,
    String? coverImageBucket,
    String? coverImagePath,
    DateTime? endsAt,
    String? description,
    List<String>? highlights,
    List<Map<String, dynamic>>? speakers,
    List<Map<String, dynamic>>? sponsors,
    List<Map<String, dynamic>>? agenda,
    String? actorRole,
  }) async {
    // ✅ AJOUTÉ: Validation des données
    if (title.trim().isEmpty) {
      throw Exception('Le titre de l\'événement est requis');
    }
    if (place.trim().isEmpty) {
      throw Exception('Le lieu de l\'événement est requis');
    }
    
    final payload = <String, dynamic>{
      if (id != null && id.trim().isNotEmpty) 'id': id.trim(),
      'title': title.trim(),
      'starts_at': startsAt.toUtc().toIso8601String(),
      if (endsAt != null) 'ends_at': endsAt.toUtc().toIso8601String(),
      'place': place.trim(),
      'virtual_link': (virtualLink ?? '').trim().isEmpty ? null : virtualLink!.trim(),
      'status': status,
      if (isFeatured != null) 'is_featured': isFeatured,
      if (quickHook != null && quickHook.trim().isNotEmpty) 'quick_hook': quickHook.trim(),
      if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
      if (maxParticipants != null) 'max_participants': maxParticipants,
      if (isFree != null) 'is_free': isFree,
      if (price != null) 'price': price,
      if (eventType != null && eventType.trim().isNotEmpty) 'event_type': eventType,
      if (meetingLink != null && meetingLink.trim().isNotEmpty) 'meeting_link': meetingLink.trim(),
      if (organizer != null && organizer.trim().isNotEmpty) 'organizer': organizer.trim(),
      if (coverImageBucket != null) 'cover_image_bucket': coverImageBucket.trim().isEmpty ? coverBucketDefault : coverImageBucket.trim(),
      if (coverImagePath != null && coverImagePath.trim().isNotEmpty) 'cover_image_path': coverImagePath.trim(),
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      if (highlights != null && highlights.isNotEmpty) 'highlights': highlights,
      if (speakers != null && speakers.isNotEmpty) 'speakers': speakers,
      if (sponsors != null && sponsors.isNotEmpty) 'sponsors': sponsors,
      if (agenda != null && agenda.isNotEmpty) 'agenda': agenda,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      debugPrint('📝 AdminEventService.upsertEvent: ${id == null ? "Création" : "Mise à jour"} de "$title"');
      
      final res = await _client.from(eventsTable).upsert(payload).select('id').maybeSingle();
      final eventId = (res?['id'] ?? id ?? '').toString();
      
      if (eventId.isEmpty) {
        throw Exception('Impossible de récupérer l\'ID de l\'événement');
      }
      
      await _audit.log(
        action: (id == null || id.trim().isEmpty) ? 'event_create' : 'event_update',
        entityType: eventsTable,
        entityId: eventId.isEmpty ? null : eventId,
        actorRole: actorRole,
        metadata: {
          'title': title.trim(),
          'starts_at': payload['starts_at'],
          'place': place.trim(),
          'virtual_link': payload['virtual_link'],
          'status': status,
          if (isFeatured != null) 'is_featured': isFeatured,
          if (category != null) 'category': category,
          if (maxParticipants != null) 'max_participants': maxParticipants,
          if (isFree != null) 'is_free': isFree,
          if (price != null) 'price': price,
          if (eventType != null) 'event_type': eventType,
          if (endsAt != null) 'ends_at': payload['ends_at'],
        },
      );
      
      debugPrint('✅ AdminEventService.upsertEvent: ID $eventId');
      return eventId;
    } catch (e) {
      debugPrint('❌ AdminEventService.upsertEvent failed err=$e');
      rethrow;
    }
  }

  // ============================================================
  // MISE À JOUR DE L'IMAGE DE COUVERTURE
  // ============================================================

  Future<void> updateCoverImage({
    required String eventId,
    required String bucket,
    required String storagePath,
    String? actorRole,
  }) async {
    final id = eventId.trim();
    if (id.isEmpty) {
      throw Exception('ID d\'événement requis');
    }
    
    try {
      debugPrint('🖼️ AdminEventService.updateCoverImage: Événement $id');
      
      await _client.from(eventsTable).update({
        'cover_image_bucket': bucket.trim().isEmpty ? coverBucketDefault : bucket.trim(),
        'cover_image_path': storagePath.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
      
      await _audit.log(
        action: 'event_cover_update',
        entityType: eventsTable,
        entityId: id,
        actorRole: actorRole,
        metadata: {'cover_image_bucket': bucket, 'cover_image_path': storagePath},
      );
      
      debugPrint('✅ AdminEventService.updateCoverImage: Image mise à jour');
    } catch (e) {
      debugPrint('❌ AdminEventService.updateCoverImage failed err=$e');
      rethrow;
    }
  }

  // ============================================================
  // SUPPRESSION D'ÉVÉNEMENT
  // ============================================================

  Future<void> deleteEvent({required String id, String? actorRole}) async {
    final eventId = id.trim();
    if (eventId.isEmpty) {
      throw Exception('ID d\'événement requis');
    }
    
    try {
      debugPrint('🗑️ AdminEventService.deleteEvent: Suppression de l\'événement $eventId');
      
      await _client.from(eventsTable).delete().eq('id', eventId);
      
      await _audit.log(
        action: 'event_delete',
        entityType: eventsTable,
        entityId: eventId,
        actorRole: actorRole,
      );
      
      debugPrint('✅ AdminEventService.deleteEvent: Événement supprimé');
    } catch (e) {
      debugPrint('❌ AdminEventService.deleteEvent failed err=$e');
      rethrow;
    }
  }

  // ============================================================
  // MÉTHODES UTILITAIRES SUPPLEMENTAIRES
  // ============================================================

  // ✅ NOUVELLE MÉTHODE: Vérifier si un événement existe
  Future<bool> eventExists(String eventId) async {
    try {
      final res = await _client
          .from(eventsTable)
          .select('id')
          .eq('id', eventId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('❌ AdminEventService.eventExists failed err=$e');
      return false;
    }
  }

  // ✅ NOUVELLE MÉTHODE: Dupliquer un événement
  Future<String> duplicateEvent(String eventId, {String? actorRole}) async {
    final original = await getEventById(eventId);
    if (original == null) {
      throw Exception('Événement original introuvable');
    }
    
    // Créer une copie avec un titre modifié
    final newTitle = '${original['title']} (Copie)';
    final startsAt = DateTime.parse(original['starts_at']);
    
    return await upsertEvent(
      title: newTitle,
      startsAt: startsAt,
      place: original['place'],
      virtualLink: original['virtual_link'],
      status: 'draft', // Mettre en brouillon par défaut
      category: original['category'],
      description: original['description'],
      actorRole: actorRole,
    );
  }

  // ✅ NOUVELLE MÉTHODE: Publier un événement
  Future<void> publishEvent(String eventId, {String? actorRole}) async {
    await upsertEvent(
      id: eventId,
      title: '', // Sera ignoré car id est fourni
      startsAt: DateTime.now(),
      place: '', // Sera ignoré
      status: 'published',
      actorRole: actorRole,
    );
    debugPrint('📢 AdminEventService.publishEvent: Événement $eventId publié');
  }

  // ✅ NOUVELLE MÉTHODE: Dépublier un événement
  Future<void> unpublishEvent(String eventId, {String? actorRole}) async {
    await upsertEvent(
      id: eventId,
      title: '', // Sera ignoré
      startsAt: DateTime.now(),
      place: '', // Sera ignoré
      status: 'draft',
      actorRole: actorRole,
    );
    debugPrint('📢 AdminEventService.unpublishEvent: Événement $eventId dépublié');
  }

  // ✅ NOUVELLE MÉTHODE: Statistiques rapides
  Future<Map<String, int>> getStats() async {
    try {
      final events = await listEvents(limit: maxLimit);
      final now = DateTime.now().toUtc().toIso8601String();
      
      final published = events.where((e) => e['status'] == 'published').length;
      final drafts = events.where((e) => e['status'] == 'draft').length;
      final upcoming = events.where((e) => 
        e['status'] == 'published' && 
        (e['starts_at'] as String).compareTo(now) > 0
      ).length;
      final past = events.where((e) => 
        e['status'] == 'published' && 
        (e['starts_at'] as String).compareTo(now) <= 0
      ).length;
      
      return {
        'total': events.length,
        'published': published,
        'drafts': drafts,
        'upcoming': upcoming,
        'past': past,
      };
    } catch (e) {
      debugPrint('❌ AdminEventService.getStats failed err=$e');
      return {
        'total': 0,
        'published': 0,
        'drafts': 0,
        'upcoming': 0,
        'past': 0,
      };
    }
  }
}
