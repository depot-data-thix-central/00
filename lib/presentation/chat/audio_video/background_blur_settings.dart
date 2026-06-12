// lib/presentation/chat/audio_video/background_blur_settings.dart
import 'package:flutter/material.dart';

class BackgroundBlurSettings extends StatefulWidget {
  const BackgroundBlurSettings({super.key});

  @override
  State<BackgroundBlurSettings> createState() => _BackgroundBlurSettingsState();
}

class _BackgroundBlurSettingsState extends State<BackgroundBlurSettings> {
  bool _isEnabled = true;
  double _blurIntensity = 0.7;
  bool _autoBackground = false;
  List<String> _selectedBackgrounds = ['original'];

  final List<Map<String, dynamic>> _backgrounds = [
    {'name': 'Original', 'value': 'original', 'icon': Icons.person, 'color': null},
    {'name': 'Flou', 'value': 'blur', 'icon': Icons.blur_on, 'color': null},
    {'name': 'Bureau', 'value': 'office', 'icon': Icons.business, 'color': Color(0xFFE3F2FD)},
    {'name': 'Salon', 'value': 'living', 'icon': Icons.home, 'color': Color(0xFFFFF3E0)},
    {'name': 'Nature', 'value': 'nature', 'icon': Icons.nature, 'color': Color(0xFFE8F5E9)},
    {'name': 'Plage', 'value': 'beach', 'icon': Icons.beach_access, 'color': Color(0xFFE1F5FE)},
    {'name': 'Ciel étoilé', 'value': 'stars', 'icon': Icons.star, 'color': Color(0xFF0B1B3D)},
  ];

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
          'Flou d\'arrière-plan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Appliquer',
              style: TextStyle(fontSize: 12, color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/400/200'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                if (_isEnabled && _selectedBackgrounds.contains('blur'))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(_blurIntensity),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Effet flou actif',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Aperçu',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Enable switch
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Effets d\'arrière-plan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Flouter ou remplacer l\'arrière-plan',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (value) => setState(() => _isEnabled = value),
                  activeColor: const Color(0xFFD4AF37),
                ),
              ],
            ),
          ),
          
          if (_isEnabled) ...[
            const SizedBox(height: 12),
            
            // Blur intensity
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Intensité du flou',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.blur_off, size: 16, color: Colors.grey),
                      Expanded(
                        child: Slider(
                          value: _blurIntensity,
                          onChanged: (value) => setState(() => _blurIntensity = value),
                          activeColor: const Color(0xFFD4AF37),
                          min: 0.1,
                          max: 1.0,
                        ),
                      ),
                      const Icon(Icons.blur_on, size: 16, color: Color(0xFFD4AF37)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Backgrounds
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arrière-plans',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _backgrounds.length,
                      itemBuilder: (context, index) {
                        final bg = _backgrounds[index];
                        final isSelected = _selectedBackgrounds.contains(bg['value']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedBackgrounds.remove(bg['value']);
                              } else {
                                _selectedBackgrounds = [bg['value']];
                              }
                            });
                          },
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: bg['color'] ?? Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(bg['icon'], size: 24, color: isSelected ? const Color(0xFFD4AF37) : Colors.grey),
                                const SizedBox(height: 4),
                                Text(
                                  bg['name'],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Auto background
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arrière-plan auto',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Changer selon l\'environnement',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  Switch(
                    value: _autoBackground,
                    onChanged: (value) => setState(() => _autoBackground = value),
                    activeColor: const Color(0xFFD4AF37),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
