// lib/presentation/chat/scheduled/scheduled_messages_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/scheduled_provider.dart';
import '../../../models/scheduled_models.dart';

class ScheduledMessagesList extends StatefulWidget {
  final String conversationId;

  const ScheduledMessagesList({
    super.key,
    required this.conversationId,
  });

  @override
  State<ScheduledMessagesList> createState() => _ScheduledMessagesListState();
}

class _ScheduledMessagesListState extends State<ScheduledMessagesList> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final provider = Provider.of<ScheduledProvider>(context, listen: false);
    await provider.loadScheduledMessages(widget.conversationId);
    setState(() => _isLoading = false);
  }

  Future<void> _cancelMessage(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler', style: TextStyle(fontSize: 16)),
        content: const Text('Voulez-vous vraiment annuler ce message programmé ?', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<ScheduledProvider>(context, listen: false);
      await provider.cancelScheduledMessage(id);
      await _loadMessages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message annulé'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  void _showSchedulePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SchedulePickerSheet(conversationId: widget.conversationId),
    ).then((_) => _loadMessages());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduledProvider>(context);
    final messages = provider.scheduledMessages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Messages programmés',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              TextButton.icon(
                onPressed: _showSchedulePicker,
                icon: const Icon(Icons.schedule, size: 14),
                label: const Text('Programmer', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4AF37)),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (messages.isEmpty)
          GestureDetector(
            onTap: _showSchedulePicker,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.schedule, size: 20, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Programmer un message',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Envoyer automatiquement plus tard',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildScheduledMessageItem(message);
            },
          ),
      ],
    );
  }

  Widget _buildScheduledMessageItem(ScheduledMessage message) {
    final isPending = message.status == 'pending';
    final isExpired = message.scheduledAt.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPending
                  ? const Color(0xFFD4AF37).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPending ? Icons.schedule : Icons.check_circle,
              size: 20,
              color: isPending ? const Color(0xFFD4AF37) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(message.scheduledAt),
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                    if (message.isRecurring) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.repeat, size: 10, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        _getRecurringLabel(message.recurringPattern ?? ''),
                        style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                      ),
                    ],
                    if (isExpired && isPending) ...[
                      const SizedBox(width: 8),
                      const Text('Expiré', style: TextStyle(fontSize: 9, color: Colors.red)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isPending && !isExpired)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
              onPressed: () => _cancelMessage(message.id),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  String _getRecurringLabel(String pattern) {
    switch (pattern) {
      case 'daily': return 'Quotidien';
      case 'weekly': return 'Hebdomadaire';
      case 'monthly': return 'Mensuel';
      default: return '';
    }
  }
}
