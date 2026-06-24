// 📁 lib/presentation/admin_hopital/interoperability/widgets/national_health_connector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class NationalHealthConnector extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onConnect;
  final Function()? onDisconnect;

  const NationalHealthConnector({
    Key? key,
    required this.onConnect,
    this.onDisconnect,
  }) : super(key: key);

  @override
  ConsumerState<NationalHealthConnector> createState() => _NationalHealthConnectorState();
}

class _NationalHealthConnectorState extends ConsumerState<NationalHealthConnector> {
  bool _isConnected = false;
  bool _isConnecting = false;
  String _status = 'Déconnecté';
  String _connectionType = 'Sécurité Sociale';
  String _lastSync = 'Jamais';
  String _syncStatus = 'En attente';
  String _apiKey = 'sk_live_****';
  bool _isEncrypted = true;

  final List<String> _connectionTypes = [
    'Sécurité Sociale',
    'Assurance Maladie',
    'ARS',
    'SIDEP',
    'DMP',
    'Autre',
  ];

  final List<String> _syncStatuses = ['En attente', 'En cours', 'Synchronisé', 'Erreur'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isConnected ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isConnected ? Icons.check_circle : Icons.cloud_off,
                  size: 22,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Connecteur National de Santé',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Type de connexion
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              value: _connectionType,
              items: _connectionTypes.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: _isConnected
                  ? null
                  : (v) => setState(() => _connectionType = v ?? _connectionType),
              decoration: InputDecoration(
                labelText: 'Type de connexion',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dernière synchronisation
          Row(
            children: [
              _buildInfoChip(Icons.sync, 'Dernière synchro: $_lastSync', Colors.blue),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.lock,
                _isEncrypted ? 'Chiffré' : 'Non chiffré',
                _isEncrypted ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Statut de synchronisation
          Row(
            children: [
              const Text(
                'Statut synchro:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _syncStatus == 'Synchronisé'
                      ? Colors.green.shade50
                      : (_syncStatus == 'En cours' ? Colors.blue.shade50 : Colors.orange.shade50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _syncStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _syncStatus == 'Synchronisé'
                        ? Colors.green.shade700
                        : (_syncStatus == 'En cours' ? Colors.blue.shade700 : Colors.orange.shade700),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'API: $_apiKey',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              if (!_isConnected)
                Expanded(
                  child: AdminGradientButton(
                    text: _isConnecting ? 'Connexion en cours...' : 'Se connecter',
                    onPressed: _isConnecting ? null : _connect,
                    icon: Icons.cloud_upload,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  ),
                )
              else ...[
                Expanded(
                  child: AdminGradientButton(
                    text: 'Synchroniser',
                    onPressed: () => _syncData(context),
                    icon: Icons.sync,
                    gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AdminGradientButton(
                    text: 'Déconnecter',
                    onPressed: () => _disconnect(context),
                    icon: Icons.cloud_off,
                    gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _status = 'Connexion...';
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isConnected = true;
      _isConnecting = false;
      _status = 'Connecté';
      _lastSync = DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16);
      _syncStatus = 'Synchronisé';
    });
    widget.onConnect({
      'type': _connectionType,
      'status': 'connected',
      'timestamp': DateTime.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecté au système national de santé'), backgroundColor: Colors.green),
    );
  }

  void _disconnect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter du système national de santé ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              setState(() {
                _isConnected = false;
                _status = 'Déconnecté';
                _syncStatus = 'En attente';
              });
              if (widget.onDisconnect != null) widget.onDisconnect!();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnecté'), backgroundColor: Colors.red),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  void _syncData(BuildContext context) {
    setState(() => _syncStatus = 'En cours');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation en cours...'), backgroundColor: Colors.blue),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _syncStatus = 'Synchronisé';
          _lastSync = DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synchronisation terminée'), backgroundColor: Colors.green),
        );
      }
    });
  }
}
