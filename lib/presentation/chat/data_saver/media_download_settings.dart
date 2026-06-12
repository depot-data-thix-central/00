// lib/presentation/chat/data_saver/media_download_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaDownloadSettings extends StatefulWidget {
  const MediaDownloadSettings({super.key});

  @override
  State<MediaDownloadSettings> createState() => _MediaDownloadSettingsState();
}

class _MediaDownloadSettingsState extends State<MediaDownloadSettings> {
  String _downloadOnMobile = 'wifi_only';
  String _videoQuality = 'auto';
  String _imageQuality = 'high';
  bool _autoPlayVideos = true;
  bool _autoPlayGifs = true;

  final List<Map<String, dynamic>> _downloadOptions = [
    {'label': 'Toujours', 'value': 'always', 'icon': Icons.download'},
    {'label': 'Wi-Fi uniquement', 'value': 'wifi_only', 'icon': Icons.wifi'},
    {'label': 'Jamais', 'value': 'never', 'icon': Icons.block},
  ];

  final List<Map<String, dynamic>> _videoQualityOptions = [
    {'label': 'Auto', 'value': 'auto', 'quality': 'Variable', 'icon': Icons.auto_awesome},
    {'label': 'Haute (HD)', 'value': 'high', 'quality': 'Jusqu\'à 1080p', 'icon': Icons.hd},
    {'label': 'Moyenne (SD)', 'value': 'medium', 'quality': '480p', 'icon': Icons.sd},
    {'label': 'Basse', 'value': 'low', 'quality': '240p', 'icon': Icons.signal_cellular_0_bar},
  ];

  final List<Map<String, dynamic>> _imageQualityOptions = [
    {'label': 'Originale', 'value': 'original', 'size': 'Taille réelle', 'icon': Icons.photo},
    {'label': 'Haute', 'value': 'high', 'size': '~500KB', 'icon': Icons.photo_size_select_large},
    {'label': 'Moyenne', 'value': 'medium', 'size': '~200KB', 'icon': Icons.photo_size_select_medium},
    {'label': 'Basse', 'value': 'low', 'size': '~50KB', 'icon': Icons.photo_size_select_small},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadOnMobile = prefs.getString('download_on_mobile') ?? 'wifi_only';
      _videoQuality = prefs.getString('video_quality') ?? 'auto';
      _imageQuality = prefs.getString('image_quality') ?? 'high';
      _autoPlayVideos = prefs.getBool('auto_play_videos') ?? true;
      _autoPlayGifs = prefs.getBool('auto_play_gifs') ?? true;
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
          'Téléchargement média',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Téléchargement sur mobile
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Téléchargement sur mobile',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                ..._downloadOptions.map((option) {
                  final isSelected = _downloadOnMobile == option['value'];
                  return RadioListTile<String>(
                    value: option['value'],
                    groupValue: _downloadOnMobile,
                    onChanged: (value) {
                      setState(() => _downloadOnMobile = value!);
                      _saveSetting('download_on_mobile', value);
                    },
                    title: Row(
                      children: [
                        Icon(option['icon'], size: 18, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
                        const SizedBox(width: 12),
                        Text(option['label'], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    activeColor: const Color(0xFFD4AF37),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }),
              ],
            ),
          ),

          // Qualité vidéo
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Qualité vidéo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                ..._videoQualityOptions.map((option) {
                  final isSelected = _videoQuality == option['value'];
                  return RadioListTile<String>(
                    value: option['value'],
                    groupValue: _videoQuality,
                    onChanged: (value) {
                      setState(() => _videoQuality = value!);
                      _saveSetting('video_quality', value);
                    },
                    title: Text(option['label'], style: const TextStyle(fontSize: 12)),
                    subtitle: Text(option['quality'], style: const TextStyle(fontSize: 9)),
                    secondary: Icon(option['icon'], size: 20, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
                    activeColor: const Color(0xFFD4AF37),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }),
              ],
            ),
          ),

          // Qualité image
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Qualité image',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                ..._imageQualityOptions.map((option) {
                  final isSelected = _imageQuality == option['value'];
                  return RadioListTile<String>(
                    value: option['value'],
                    groupValue: _imageQuality,
                    onChanged: (value) {
                      setState(() => _imageQuality = value!);
                      _saveSetting('image_quality', value);
                    },
                    title: Text(option['label'], style: const TextStyle(fontSize: 12)),
                    subtitle: Text(option['size'], style: const TextStyle(fontSize: 9)),
                    secondary: Icon(option['icon'], size: 20, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
                    activeColor: const Color(0xFFD4AF37),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }),
              ],
            ),
          ),

          // Lecture automatique
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Lecture auto des vidéos', style: TextStyle(fontSize: 13)),
                  subtitle: const Text('Lire automatiquement les vidéos', style: TextStyle(fontSize: 10)),
                  value: _autoPlayVideos,
                  onChanged: (value) {
                    setState(() => _autoPlayVideos = value);
                    _saveSetting('auto_play_videos', value);
                  },
                  activeColor: const Color(0xFFD4AF37),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Lecture auto des GIF', style: TextStyle(fontSize: 13)),
                  subtitle: const Text('Animer automatiquement les GIF', style: TextStyle(fontSize: 10)),
                  value: _autoPlayGifs,
                  onChanged: (value) {
                    setState(() => _autoPlayGifs = value);
                    _saveSetting('auto_play_gifs', value);
                  },
                  activeColor: const Color(0xFFD4AF37),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),

          // Information
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                        'Économie de données',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Les réglages basse qualité peuvent réduire la consommation de données jusqu\'à 70%',
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
