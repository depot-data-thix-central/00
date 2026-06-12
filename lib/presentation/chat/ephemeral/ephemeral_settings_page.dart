// lib/presentation/chat/ephemeral/ephemeral_settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/ephemeral_provider.dart';
import '../../../providers/auth_controller.dart';

class EphemeralSettingsPage extends StatefulWidget {
  const EphemeralSettingsPage({super.key});

  @override
  State<EphemeralSettingsPage> createState() => _EphemeralSettingsPageState();
}

class _EphemeralSettingsPageState extends State<EphemeralSettingsPage> {
  late EphemeralProvider _ephemeralProvider;
  bool _isLoading = true;

  // Durées disponibles (en secondes)
  final List<Map<String, dynamic>> _durations = [
    {'label': '5 secondes', 'value': 5},
    {'label': '10 secondes', 'value': 10},
    {'label': '30 secondes', 'value': 30},
    {'label': '1 minute', 'value': 60},
    {'label': '5 minutes', 'value': 300},
    {'label': '1 heure', 'value': 3600},
    {'label': '24 heures', 'value': 86400},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _ephemeralProvider = Provider.of<EphemeralProvider>(context, listen: false);
    await _ephemeralProvider.loadSettings();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final settings = _ephemeralProvider.settings;
    final isEnabled = _ephemeralProvider.isEnabled;

    if (auth.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Connectez-vous pour accéder aux paramètres'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                ),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mode confidentiel',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          Switch(
            value: isEnabled,
            onChanged: (value) => _ephemeralProvider.toggleEnabled(value),
            activeColor: const Color(0xFFD4AF37),
          ),
        ],
      ),
      body: isEnabled ? _buildEnabledContent(settings) : _buildDisabledContent(),
    );
  }

  Widget _buildDisabledContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.visibility_off,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mode confidentiel désactivé',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activez le mode confidentiel pour envoyer\n des messages qui disparaissent',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _ephemeralProvider.toggleEnabled(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Activer', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildEnabledContent(EphemeralSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Color(0xFFD4AF37)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Mode confidentiel activé',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Les messages disparaîtront après la durée définie. Les captures d\'écran seront détectées.',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Durée par défaut
          const Text(
            'Durée de vie des messages',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _durations.map((duration) {
                final isSelected = settings.defaultDuration == duration['value'];
                return RadioListTile<int>(
                  value: duration['value'],
                  groupValue: settings.defaultDuration,
                  onChanged: (value) {
                    if (value != null) {
                      _ephemeralProvider.updateDefaultDuration(value);
                    }
                  },
                  title: Text(
                    duration['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  activeColor: const Color(0xFFD4AF37),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Notification de capture
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détection de capture',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Recevoir une notification si quelqu\'un capture l\'écran',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.notifyScreenshot,
                  onChanged: (value) => _ephemeralProvider.updateNotifyScreenshot(value),
                  activeColor: const Color(0xFFD4AF37),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Historique des alertes
          const Text(
            'Alertes de capture',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildAlertsList(),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = _ephemeralProvider.screenshotAlerts;

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.security, size: 32, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Aucune alerte',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: alerts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            leading: const Icon(Icons.camera_alt, size: 16, color: Colors.red),
            title: Text(
              alert.userName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _formatDate(alert.capturedAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            trailing: const Icon(Icons.warning, size: 14, color: Colors.red),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inHours < 1) return 'il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'il y a ${diff.inHours} h';
    return '${date.day}/${date.month}/${date.year}';
  }
}
