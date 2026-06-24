// 📁 lib/presentation/admin_hopital/security/screens/security_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/two_factor_setup.dart';
import '../widgets/encryption_status.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _isLoading = false;
  bool _twoFactorEnabled = false;
  bool _encryptionEnabled = true;
  String _encryptionType = 'AES-256-GCM';
  DateTime _lastRotation = DateTime.now().subtract(const Duration(days: 45));
  bool _sessionTimeoutEnabled = true;
  int _sessionTimeoutMinutes = 30;
  bool _ipRestrictionEnabled = false;
  List<String> _allowedIps = ['192.168.1.0/24'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de sécurité'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paramètres sauvegardés'), backgroundColor: Colors.green),
              );
            },
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Double authentification
              TwoFactorSetup(
                initialStatus: _twoFactorEnabled,
                onToggle: (v) => setState(() => _twoFactorEnabled = v),
              ),
              const SizedBox(height: 16),
              // Chiffrement
              EncryptionStatus(
                isEnabled: _encryptionEnabled,
                encryptionType: _encryptionType,
                lastRotation: _lastRotation,
              ),
              const SizedBox(height: 16),
              // Autres paramètres
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
                    const Text(
                      'Paramètres avancés',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchTile(
                      title: 'Expiration de session',
                      subtitle: 'Déconnecter automatiquement après une période d\'inactivité',
                      value: _sessionTimeoutEnabled,
                      onChanged: (v) => setState(() => _sessionTimeoutEnabled = v),
                    ),
                    if (_sessionTimeoutEnabled) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Durée (minutes)',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 80,
                            child: DropdownButtonFormField<int>(
                              value: _sessionTimeoutMinutes,
                              items: [15, 30, 45, 60, 120].map((m) {
                                return DropdownMenuItem(
                                  value: m,
                                  child: Text('$m', style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _sessionTimeoutMinutes = v ?? 30),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    _buildSwitchTile(
                      title: 'Restriction IP',
                      subtitle: 'Limiter l\'accès à certaines adresses IP',
                      value: _ipRestrictionEnabled,
                      onChanged: (v) => setState(() => _ipRestrictionEnabled = v),
                    ),
                    if (_ipRestrictionEnabled) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _allowedIps.map((ip) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.public, size: 14, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text(ip, style: const TextStyle(fontSize: 12))),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 14, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _allowedIps.remove(ip);
                                    });
                                  },
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AdminGradientButton(
                        text: 'Ajouter une IP',
                        onPressed: () {
                          // Simuler l'ajout d'une IP
                          setState(() {
                            _allowedIps.add('192.168.1.100');
                          });
                        },
                        height: 34,
                        width: 150,
                        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AdminGradientButton(
                text: 'Appliquer tous les paramètres',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paramètres appliqués'), backgroundColor: Colors.green),
                  );
                },
                icon: Icons.apply,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ],
    );
  }
}
