// 📁 lib/presentation/admin_hopital/messaging/widgets/message_composer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_dropdown.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_search_bar.dart';

class MessageComposer extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSend;
  final String? initialRecipient;
  final String? initialSubject;
  final String? initialBody;

  const MessageComposer({
    Key? key,
    required this.onSend,
    this.initialRecipient,
    this.initialSubject,
    this.initialBody,
  }) : super(key: key);

  @override
  ConsumerState<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends ConsumerState<MessageComposer> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _recipientCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  // Valeurs
  String _priority = 'normal';
  bool _isUrgent = false;
  bool _isEncrypted = false;
  bool _requestReadReceipt = false;
  List<String> _attachments = [];

  final List<String> _priorities = ['normal', 'important', 'urgent'];

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipient != null) {
      _recipientCtrl.text = widget.initialRecipient!;
    }
    if (widget.initialSubject != null) {
      _subjectCtrl.text = widget.initialSubject!;
    }
    if (widget.initialBody != null) {
      _bodyCtrl.text = widget.initialBody!;
    }
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Nouveau message',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_attachments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_attachments.length} pièce(s) jointe(s)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Destinataire
            AdminFormField(
              label: 'Destinataire *',
              controller: _recipientCtrl,
              hint: 'Nom du destinataire ou service...',
              validator: (v) => v?.isEmpty == true ? 'Destinataire requis' : null,
            ),
            const SizedBox(height: 12),

            // Objet
            AdminFormField(
              label: 'Objet *',
              controller: _subjectCtrl,
              hint: 'Sujet du message...',
              validator: (v) => v?.isEmpty == true ? 'Objet requis' : null,
            ),
            const SizedBox(height: 12),

            // Corps du message
            AdminFormField(
              label: 'Message *',
              controller: _bodyCtrl,
              hint: 'Rédigez votre message...',
              maxLines: 5,
              validator: (v) => v?.isEmpty == true ? 'Message requis' : null,
            ),
            const SizedBox(height: 12),

            // Options
            Row(
              children: [
                Expanded(
                  child: AdminDropdown<String>(
                    label: 'Priorité',
                    value: _priority,
                    items: _priorities.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getPriorityColor(p),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(_getPriorityLabel(p), style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _priority = v ?? _priority;
                      _isUrgent = v == 'urgent';
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isEncrypted,
                          onChanged: (v) => setState(() => _isEncrypted = v ?? false),
                          activeColor: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Chiffré',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isEncrypted ? Colors.blue : Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: _requestReadReceipt,
                          onChanged: (v) => setState(() => _requestReadReceipt = v ?? false),
                          activeColor: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Accusé réception',
                          style: TextStyle(
                            fontSize: 12,
                            color: _requestReadReceipt ? Colors.blue : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pièces jointes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Pièces jointes',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Ajouter une pièce jointe
                      setState(() {
                        _attachments.add('Document_${_attachments.length + 1}.pdf');
                      });
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _attachments.map((file) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 12, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        file,
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachments.remove(file);
                          });
                        },
                        child: const Icon(Icons.close, size: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],

            const SizedBox(height: 16),

            AdminGradientButton(
              text: 'Envoyer le message',
              onPressed: _sendMessage,
              icon: Icons.send,
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'important':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'important':
        return 'Important';
      default:
        return 'Normal';
    }
  }

  void _sendMessage() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'recipient': _recipientCtrl.text,
      'subject': _subjectCtrl.text,
      'body': _bodyCtrl.text,
      'priority': _priority,
      'isUrgent': _isUrgent,
      'isEncrypted': _isEncrypted,
      'requestReadReceipt': _requestReadReceipt,
      'attachments': _attachments,
      'date': DateTime.now(),
    };

    widget.onSend(data);
  }
}
