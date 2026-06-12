// lib/presentation/chat/themes/theme_selector_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSelectorSheet extends StatefulWidget {
  const ThemeSelectorSheet({super.key});

  @override
  State<ThemeSelectorSheet> createState() => _ThemeSelectorSheetState();
}

class _ThemeSelectorSheetState extends State<ThemeSelectorSheet> {
  String _selectedTheme = 'light';
  
  final List<Map<String, dynamic>> _themes = [
    {'name': 'Clair', 'value': 'light', 'icon': Icons.light_mode, 'color': Colors.white, 'bgColor': Color(0xFFF5F5F5)},
    {'name': 'Sombre', 'value': 'dark', 'icon': Icons.dark_mode, 'color': Color(0xFF1A1A1A), 'bgColor': Color(0xFF121212)},
    {'name': 'THIX Or', 'value': 'thix', 'icon': Icons.star, 'color': Color(0xFFD4AF37), 'bgColor': Color(0xFF0B1B3D)},
    {'name': 'Bleu', 'value': 'blue', 'icon': Icons.forest, 'color': Colors.blue, 'bgColor': Color(0xFFE3F2FD)},
    {'name': 'Vert', 'value': 'green', 'icon': Icons.eco, 'color': Colors.green, 'bgColor': Color(0xFFE8F5E9)},
    {'name': 'Rouge', 'value': 'red', 'icon': Icons.favorite, 'color': Colors.red, 'bgColor': Color(0xFFFFEBEE)},
    {'name': 'Violet', 'value': 'purple', 'icon': Icons.stars, 'color': Colors.purple, 'bgColor': Color(0xFFF3E5F5)},
    {'name': 'Orange', 'value': 'orange', 'icon': Icons.brightness_low, 'color': Colors.orange, 'bgColor': Color(0xFFFFF3E0)},
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('chat_theme') ?? 'light';
    });
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_theme', theme);
    setState(() => _selectedTheme = theme);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choisir un thème',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _themes.map((theme) {
              final isSelected = _selectedTheme == theme['value'];
              return GestureDetector(
                onTap: () {
                  _saveTheme(theme['value']);
                  Navigator.pop(context, theme['value']);
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme['color'],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 8)]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          theme['icon'],
                          size: 28,
                          color: theme['value'] == 'light' ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      theme['name'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
