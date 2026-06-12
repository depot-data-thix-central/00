// lib/presentation/chat/themes/chat_wallpaper_picker.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatWallpaperPicker extends StatefulWidget {
  const ChatWallpaperPicker({super.key});

  @override
  State<ChatWallpaperPicker> createState() => _ChatWallpaperPickerState();
}

class _ChatWallpaperPickerState extends State<ChatWallpaperPicker> {
  String _selectedWallpaper = 'default';
  double _opacity = 0.3;
  bool _applyToAllChats = false;

  final List<Map<String, dynamic>> _wallpapers = [
    {'name': 'Par défaut', 'value': 'default', 'image': null, 'color': Color(0xFFF8F9FA)},
    {'name': 'Dégradé THIX', 'value': 'thix', 'image': null, 'color': Color(0xFF0B1B3D)},
    {'name': 'Nature', 'value': 'nature', 'image': 'assets/wallpapers/nature.jpg', 'color': null},
    {'name': 'Ville', 'value': 'city', 'image': 'assets/wallpapers/city.jpg', 'color': null},
    {'name': 'Abstrait', 'value': 'abstract', 'image': 'assets/wallpapers/abstract.jpg', 'color': null},
    {'name': 'Sombre', 'value': 'dark', 'image': null, 'color': Color(0xFF121212)},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedWallpaper = prefs.getString('chat_wallpaper') ?? 'default';
      _opacity = prefs.getDouble('wallpaper_opacity') ?? 0.3;
      _applyToAllChats = prefs.getBool('wallpaper_apply_all') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
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
          'Fond d\'écran du chat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Preview
          Container(
            height: 200,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: _getWallpaperImage(),
              color: _getWallpaperColor(),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(_opacity),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Aperçu',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Opacity
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
                  'Opacité',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.brightness_low, size: 16, color: Colors.grey),
                    Expanded(
                      child: Slider(
                        value: _opacity,
                        min: 0.1,
                        max: 0.8,
                        divisions: 10,
                        onChanged: (value) {
                          setState(() => _opacity = value);
                          _saveSetting('wallpaper_opacity', value);
                        },
                        activeColor: const Color(0xFFD4AF37),
                      ),
                    ),
                    const Icon(Icons.brightness_high, size: 16, color: Color(0xFFD4AF37)),
                  ],
                ),
              ],
            ),
          ),
          
          // Wallpapers grid
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
                  'Fonds d\'écran',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _wallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = _wallpapers[index];
                    final isSelected = _selectedWallpaper == wallpaper['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedWallpaper = wallpaper['value']);
                        _saveSetting('chat_wallpaper', wallpaper['value']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  image: wallpaper['image'] != null
                                      ? DecorationImage(image: AssetImage(wallpaper['image']), fit: BoxFit.cover)
                                      : null,
                                  color: wallpaper['color'],
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD4AF37),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                                  ),
                                ),
                              Positioned(
                                bottom: 4,
                                left: 0,
                                right: 0,
                                child: Text(
                                  wallpaper['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Apply to all chats
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Appliquer à toutes les conversations', style: TextStyle(fontSize: 13)),
              value: _applyToAllChats,
              onChanged: (value) {
                setState(() => _applyToAllChats = value);
                _saveSetting('wallpaper_apply_all', value);
              },
              activeColor: const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  DecorationImage? _getWallpaperImage() {
    final wallpaper = _wallpapers.firstWhere((w) => w['value'] == _selectedWallpaper);
    if (wallpaper['image'] != null) {
      return DecorationImage(image: AssetImage(wallpaper['image']), fit: BoxFit.cover);
    }
    return null;
  }

  Color? _getWallpaperColor() {
    final wallpaper = _wallpapers.firstWhere((w) => w['value'] == _selectedWallpaper);
    return wallpaper['color'];
  }
}
