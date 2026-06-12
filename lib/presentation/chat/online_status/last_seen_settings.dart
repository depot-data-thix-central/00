// lib/presentation/chat/online_status/last_seen_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastSeenSettings extends StatefulWidget {
  const LastSeenSettings({super.key});

  @override
  State<LastSeenSettings> createState() => _LastSeenSettingsState();
}

class _LastSeenSettingsState extends State<LastSeenSettings> {
  String _lastSeenSetting = 'everyone';
  bool _showTyping = true;
  bool _showReadReceipts = true;

  final List<Map<String, dynamic>> _privacyOptions = [
    {'name': 'Tout le monde', 'value': 'everyone', 'icon': Icons.public, 'desc': 'Tout le monde peut voir'},
    {'name': 'Mes contacts', 'value': 'contacts', 'icon': Icons.people, 'desc': 'Uniquement mes contacts'},
    {'name': 'Personne', 'value': 'nobody', 'icon': Icons.lock, 'desc': 'Personne ne peut voir'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSeenSetting = prefs.getString('last_seen_privacy') ?? 'everyone';
      _showTyping = prefs.getBool('show_typing_status') ?? true;
      _showReadReceipts = prefs.getBool('show_read_receipts') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Dernière connexion',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Last seen privacy
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Qui peut voir ma dernière connexion',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ..._privacyOptions.map((option) {
                  final isSelected = _lastSeenSetting == option['value'];
                  return RadioListTile<String>(
                    value: option['value'],
                    groupValue: _lastSeenSetting,
                    onChanged: (value) {
                      setState(() => _lastSeenSetting = value!);
                      _saveSetting('last_seen_privacy', value);
                    },
                    title: Text(option['name'], style: const TextStyle(fontSize: 12)),
                    subtitle: Text(option['desc'], style: const TextStyle(fontSize: 10)),
                    secondary: Icon(option['icon'], size: 18, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
                    activeColor: const Color(0xFFD4AF37),
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          
          // Typing status
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Montrer que j\'écris', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Les autres voient quand vous tapez un message', style: TextStyle(fontSize: 10)),
              value: _showTyping,
              onChanged: (value) {
                setState(() => _showTyping = value);
                _saveSetting('show_typing_status', value);
              },
              activeColor: const Color(0xFFD4AF37),
            ),
          ),
          
          // Read receipts
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Accusés de lecture', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Les autres voient quand vous lisez leurs messages', style: TextStyle(fontSize: 10)),
              value: _showReadReceipts,
              onChanged: (value) {
                setState(() => _showReadReceipts = value);
                _saveSetting('show_read_receipts', value);
              },
              activeColor: const Color(0xFFD4AF37),
            ),
          ),
          
          // Info
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Color(0xFFD4AF37)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'À propos',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Si vous désactivez les accusés, vous ne verrez pas non plus ceux des autres.',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
