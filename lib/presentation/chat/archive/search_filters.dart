// lib/presentation/chat/archive/search_filters.dart
import 'package:flutter/material.dart';

class SearchFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const SearchFilters({super.key, required this.onApplyFilters});

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  String _selectedType = 'all';
  String _selectedDate = 'anytime';
  String _selectedSort = 'date_desc';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasMedia = false;
  
  final List<Map<String, dynamic>> _types = [
    {'label': 'Tous', 'value': 'all', 'icon': Icons.all_inclusive},
    {'label': 'Messages', 'value': 'message', 'icon': Icons.chat},
    {'label': 'Images', 'value': 'image', 'icon': Icons.image},
    {'label': 'Vidéos', 'value': 'video', 'icon': Icons.videocam},
    {'label': 'Fichiers', 'value': 'file', 'icon': Icons.insert_drive_file},
    {'label': 'Liens', 'value': 'link', 'icon': Icons.link},
  ];
  
  final List<Map<String, String>> _dateRanges = [
    {'label': 'À tout moment', 'value': 'anytime'},
    {'label': "Aujourd'hui", 'value': 'today'},
    {'label': 'Hier', 'value': 'yesterday'},
    {'label': 'Cette semaine', 'value': 'week'},
    {'label': 'Ce mois', 'value': 'month'},
    {'label': 'Personnalisé', 'value': 'custom'},
  ];
  
  final List<Map<String, String>> _sortOptions = [
    {'label': 'Plus récent', 'value': 'date_desc'},
    {'label': 'Plus ancien', 'value': 'date_asc'},
    {'label': 'Plus pertinent', 'value': 'relevance'},
  ];

  void _apply() {
    final filters = {
      'type': _selectedType,
      'dateRange': _selectedDate,
      'sortBy': _selectedSort,
      'hasMedia': _hasMedia,
      'startDate': _startDate,
      'endDate': _endDate,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _selectedType = 'all';
      _selectedDate = 'anytime';
      _selectedSort = 'date_desc';
      _hasMedia = false;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filtres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('Réinitialiser', style: TextStyle(fontSize: 12, color: Color(0xFFD4AF37))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type
          const Text('Type de contenu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((type) {
              final isSelected = _selectedType == type['value'];
              return FilterChip(
                label: Text(type['label'], style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedType = type['value']),
                avatar: Icon(type['icon'], size: 14),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFD4AF37).withOpacity(0.15),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Période
          const Text('Période', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dateRanges.map((range) {
              final isSelected = _selectedDate == range['value'];
              return FilterChip(
                label: Text(range['label'], style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedDate = range['value']),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFD4AF37).withOpacity(0.15),
              );
            }).toList(),
          ),
          
          if (_selectedDate == 'custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _startDate = date);
                    },
                    child: Text(
                      _startDate != null
                          ? 'Du ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Date de début',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _endDate = date);
                    },
                    child: Text(
                      _endDate != null
                          ? 'Au ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Date de fin',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Tri
          const Text('Trier par', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._sortOptions.map((option) {
            final isSelected = _selectedSort == option['value'];
            return RadioListTile<String>(
              value: option['value'],
              groupValue: _selectedSort,
              onChanged: (value) => setState(() => _selectedSort = value!),
              title: Text(option['label'], style: const TextStyle(fontSize: 12)),
              activeColor: const Color(0xFFD4AF37),
              contentPadding: EdgeInsets.zero,
            );
          }),
          
          const SizedBox(height: 24),
          
          // Médias uniquement
          CheckboxListTile(
            title: const Text('Fichiers avec médias uniquement', style: TextStyle(fontSize: 12)),
            value: _hasMedia,
            onChanged: (value) => setState(() => _hasMedia = value ?? false),
            activeColor: const Color(0xFFD4AF37),
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 32),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Appliquer les filtres', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
