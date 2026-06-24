// 📁 lib/presentation/admin_hopital/messaging/screens/message_inbox_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/message_list_tile.dart';
import '../widgets/message_notification_badge.dart';
import '../../common/widgets/admin_search_bar.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_empty_state.dart';
import '../../common/widgets/admin_gradient_button.dart';
import '../../common/widgets/admin_confirm_dialog.dart';

// Provider à créer pour la messagerie
// import '../../common/providers/admin_message_provider.dart';

class MessageInboxScreen extends ConsumerStatefulWidget {
  const MessageInboxScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageInboxScreen> createState() => _MessageInboxScreenState();
}

class _MessageInboxScreenState extends ConsumerState<MessageInboxScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, unread, urgent, sent
  bool _isLoading = true;
  int _selectedCount = 0;

  // Données mockées (à remplacer par le provider)
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'sender': 'Dr. Martin',
      'senderAvatar': 'M',
      'subject': 'Résultats d\'analyse - Patient Michel Dupont',
      'preview': 'Les résultats d\'analyse sont disponibles. Merci de les consulter...',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'isUrgent': true,
      'hasAttachment': true,
    },
    {
      'id': '2',
      'sender': 'Pharmacie Dubois',
      'senderAvatar': 'D',
      'subject': 'Confirmation de dispensation',
      'preview': 'Les médicaments pour le patient Sophie Martin ont été dispensés...',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
      'isUrgent': false,
      'hasAttachment': false,
    },
    {
      'id': '3',
      'sender': 'Dr. Bernard',
      'senderAvatar': 'B',
      'subject': 'Demande de téléexpertise',
      'preview': 'Je sollicite votre avis sur le cas de Lucas Bernard...',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'isUrgent': false,
      'hasAttachment': false,
    },
    {
      'id': '4',
      'sender': 'Service des soins',
      'senderAvatar': 'S',
      'subject': 'Planification des soins - Semaine 51',
      'preview': 'Veuillez consulter le planning des soins pour la semaine prochaine...',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'isUrgent': false,
      'hasAttachment': true,
    },
    {
      'id': '5',
      'sender': 'Dr. Petit',
      'senderAvatar': 'P',
      'subject': 'URGENT - Transfert patient',
      'preview': 'Patient en état critique, transfert immédiat vers les urgences...',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'isRead': false,
      'isUrgent': true,
      'hasAttachment': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    // Simuler le chargement
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredMessages {
    var filtered = _messages;

    // Recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) =>
        m['sender'].toLowerCase().contains(query) ||
        m['subject'].toLowerCase().contains(query) ||
        m['preview'].toLowerCase().contains(query)
      ).toList();
    }

    // Filtre par statut
    if (_filterStatus == 'unread') {
      filtered = filtered.where((m) => !m['isRead']).toList();
    } else if (_filterStatus == 'urgent') {
      filtered = filtered.where((m) => m['isUrgent']).toList();
    } else if (_filterStatus == 'sent') {
      // Pour l'exemple, on simule des messages envoyés
      filtered = filtered.where((m) => m['isRead']).toList();
    }

    return filtered;
  }

  int get _unreadCount => _messages.where((m) => !m['isRead']).length;
  int get _urgentCount => _messages.where((m) => m['isUrgent']).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          // Badge de notifications
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_unreadCount non lu${_unreadCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: 'Rafraîchir',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AdminSearchBar(
                    onSearch: (query) => setState(() => _searchQuery = query),
                    hintText: 'Rechercher un message...',
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'unread', child: Text('Non lus', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgents', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'sent', child: Text('Envoyés', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (v) => setState(() => _filterStatus = v ?? 'all'),
                    underline: const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des messages...',
        child: Column(
          children: [
            // Barre de statistiques
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  Text(
                    '${filtered.length} message${filtered.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (_urgentCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_urgentCount urgent${_urgentCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 0),
            // Liste des messages
            Expanded(
              child: filtered.isEmpty && !_isLoading
                  ? const AdminEmptyState(
                      title: 'Aucun message',
                      subtitle: 'Votre boîte de réception est vide',
                      icon: Icons.inbox_outlined,
                      actionText: 'Composer un message',
                      onAction: null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final msg = filtered[index];
                        return MessageListTile(
                          id: msg['id']!,
                          senderName: msg['sender']!,
                          senderAvatar: msg['senderAvatar']!,
                          subject: msg['subject']!,
                          preview: msg['preview']!,
                          date: msg['date']!,
                          isRead: msg['isRead']!,
                          hasAttachment: msg['hasAttachment']!,
                          isUrgent: msg['isUrgent']!,
                          onTap: () {
                            // Marquer comme lu
                            setState(() {
                              msg['isRead'] = true;
                            });
                            // Naviguer vers le détail
                            context.push('/admin/messages/${msg['id']}');
                          },
                          onLongPress: () {
                            setState(() {
                              msg['isRead'] = !msg['isRead'];
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/messages/compose');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Nouveau message',
      ),
    );
  }
}
