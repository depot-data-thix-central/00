// 📁 lib/presentation/admin_hopital/interoperability/screens/sns_connection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/national_health_connector.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SnsConnectionScreen extends ConsumerStatefulWidget {
  const SnsConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SnsConnectionScreen> createState() => _SnsConnectionScreenState();
}

class _SnsConnectionScreenState extends ConsumerState<SnsConnectionScreen> {
  bool _isLoading = false;
  bool _isConnected = false;
  String _connectionType = 'Sécurité Sociale';
  final List<Map<String, dynamic>> _syncLog = [];
  String _lastSync = 'Jamais';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecteur National de Santé'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Connexion en cours...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              NationalHealthConnector(
                onConnect: (data) {
                  setState(() {
                    _isConnected = true;
                    _connectionType = data['type'];
                    _lastSync = DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16);
                  });
                  _addLogEntry('Connexion établie avec ${data['type']}');
                },
                onDisconnect: () {
                  setState(() {
                    _isConnected = false;
                  });
                  _addLogEntry('Déconnexion du système national');
                },
              ),
              const SizedBox(height: 16),

              // Journal de synchronisation
              Container(
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
                        const Icon(Icons.history, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Journal de synchronisation',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          'Dernière: $_lastSync',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_syncLog.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Aucune activité de synchronisation',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _syncLog.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = _syncLog[_syncLog.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  entry['type'] == 'success'
                                      ? Icons.check_circle
                                      : (entry['type'] == 'warning'
                                          ? Icons.warning_amber
                                          : Icons.info_outline),
                                  size: 16,
                                  color: entry['type'] == 'success'
                                      ? Colors.green
                                      : (entry['type'] == 'warning'
                                          ? Colors.orange
                                          : Colors.blue),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry['message'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Text(
                                  entry['time'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Service status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isConnected ? Colors.green.shade200 : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.warning_amber,
                      color: _isConnected ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isConnected
                                ? 'Connecté au système national'
                                : 'Non connecté',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isConnected ? Colors.green : Colors.orange,
                            ),
                          ),
                          Text(
                            _isConnected
                                ? 'Les données sont synchronisées avec $_connectionType'
                                : 'Connectez-vous pour synchroniser les données',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isConnected ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addLogEntry(String message, {String type = 'info'}) {
    setState(() {
      _syncLog.add({
        'message': message,
        'type': type,
        'time': DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16),
      });
    });
  }
}
