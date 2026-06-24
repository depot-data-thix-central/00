// 📁 lib/presentation/admin_hopital/interoperability/widgets/webhook_config.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_confirm_dialog.dart';

class WebhookConfig extends ConsumerStatefulWidget {
  final Function(List<Map<String, dynamic>>) onUpdate;

  const WebhookConfig({Key? key, required this.onUpdate}) : super(key: key);

  @override
  ConsumerState<WebhookConfig> createState() => _WebhookConfigState();
}

class _WebhookConfigState extends ConsumerState<WebhookConfig> {
  final List<Map<String, dynamic>> _webhooks = [
    {
      'id': '1',
      'name': 'Laboratoire externe',
      'url': 'https://api.labo.fr/webhook',
      'events': ['exam_results'],
      'secret': 'whsec_****',
      'active': true,
      'lastTriggered': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'name': 'Système d\'alertes',
      'url': 'https://alerts.hopital.fr/webhook',
      'events': ['critical_alerts', 'patient_admission'],
      'secret': 'whsec_****',
      'active': true,
      'lastTriggered': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  bool _showAddForm = false;
  String _newName = '';
  String _newUrl = '';
  List<String> _selectedEvents = [];
  String _newSecret = '';

  final List<String> _availableEvents = [
    'exam_results',
    'critical_alerts',
    'patient_admission',
    'patient_discharge',
    'prescription_created',
    'prescription_validated',
    'appointment_scheduled',
    'appointment_cancelled',
    'bed_status_change',
    'inventory_update',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.webhook, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Webhooks',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              AdminGradientButton(
                text: _showAddForm ? 'Annuler' : 'Ajouter',
                onPressed: () => setState(() => _showAddForm = !_showAddForm),
                icon: _showAddForm ? Icons.close : Icons.add,
                height: 34,
                width: 100,
                gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Formulaire d'ajout
          if (_showAddForm)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => setState(() => _newName = v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'URL *',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => setState(() => _newUrl = v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Secret (optionnel)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => setState(() => _newSecret = v),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Événements',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _availableEvents.map((event) {
                      final isSelected = _selectedEvents.contains(event);
                      return FilterChip(
                        label: Text(
                          event.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedEvents.add(event);
                            } else {
                              _selectedEvents.remove(event);
                            }
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.purple,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  AdminGradientButton(
                    text: 'Créer le webhook',
                    onPressed: _newName.isNotEmpty && _newUrl.isNotEmpty && _selectedEvents.isNotEmpty
                        ? _addWebhook
                        : null,
                    icon: Icons.save,
                    height: 38,
                    gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
                  ),
                ],
              ),
            ),

          if (_showAddForm) const SizedBox(height: 12),

          // Liste des webhooks
          ..._webhooks.map((webhook) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: webhook['active'] ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: webhook['active'] ? Colors.green.shade200 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: webhook['active'] ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.webhook,
                        size: 18,
                        color: webhook['active'] ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            webhook['name'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: webhook['active'] ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            webhook['url'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: webhook['active'],
                      onChanged: (v) => _toggleWebhook(webhook, v),
                      activeColor: Colors.green,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => _deleteWebhook(webhook),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...(webhook['events'] as List).map((event) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: webhook['active'] ? Colors.purple.shade50 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          color: webhook['active'] ? Colors.purple.shade700 : Colors.grey.shade500,
                        ),
                      ),
                    )),
                    const Spacer(),
                    Text(
                      'Dernier: ${webhook['lastTriggered'].day}/${webhook['lastTriggered'].month}/${webhook['lastTriggered'].year}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _addWebhook() {
    setState(() {
      _webhooks.add({
        'id': '${DateTime.now().millisecondsSinceEpoch}',
        'name': _newName,
        'url': _newUrl,
        'events': List.from(_selectedEvents),
        'secret': _newSecret.isNotEmpty ? _newSecret : 'whsec_****',
        'active': true,
        'lastTriggered': DateTime.now(),
      });
      _newName = '';
      _newUrl = '';
      _selectedEvents = [];
      _newSecret = '';
      _showAddForm = false;
    });
    widget.onUpdate(_webhooks);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Webhook créé'), backgroundColor: Colors.green),
    );
  }

  void _toggleWebhook(Map<String, dynamic> webhook, bool active) {
    setState(() {
      webhook['active'] = active;
    });
    widget.onUpdate(_webhooks);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(active ? 'Webhook activé' : 'Webhook désactivé'),
        backgroundColor: active ? Colors.green : Colors.orange,
      ),
    );
  }

  void _deleteWebhook(Map<String, dynamic> webhook) async {
    final confirm = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer le webhook',
      message: 'Êtes-vous sûr de vouloir supprimer le webhook "${webhook['name']}" ?',
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
    );
    if (confirm == true) {
      setState(() {
        _webhooks.remove(webhook);
      });
      widget.onUpdate(_webhooks);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Webhook supprimé'), backgroundColor: Colors.red),
      );
    }
  }
}
