// lib/presentation/chat/archive/archive_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/archive_models.dart';

class ArchiveListItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;

  const ArchiveListItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onUnarchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (item is ArchivedConversation) {
      return _buildConversationItem(item as ArchivedConversation);
    }
    return const SizedBox.shrink();
  }

  Widget _buildConversationItem(ArchivedConversation conv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: conv.avatarUrl != null
                          ? NetworkImage(conv.avatarUrl!)
                          : null,
                      child: conv.avatarUrl == null
                          ? const Icon(Icons.group, size: 24)
                          : null,
                    ),
                    if (conv.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(fontSize: 8, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatDate(conv.lastMessageAt),
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.archive, size: 12, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.unarchive, size: 18, color: Color(0xFFD4AF37)),
                      onPressed: onUnarchive,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(date);
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return DateFormat('dd/MM/yy').format(date);
  }
}
