// lib/presentation/chat/archive/export_chat_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../providers/archive_provider.dart';

class ExportChatPage extends StatefulWidget {
  final String conversationId;
  final String conversationName;

  const ExportChatPage({
    super.key,
    required this.conversationId,
    required this.conversationName,
  });

  @override
  State<ExportChatPage> createState() => _ExportChatPageState();
}

class _ExportChatPageState extends State<ExportChatPage> {
  bool _includeMedia = true;
  bool _includeDate = true;
  bool _includeTime = true;
  String _selectedFormat = 'txt';
  String _selectedDateRange = 'all';
  bool _isExporting = false;

  final List<Map<String, dynamic>> _formats = [
    {'label': 'Texte (.txt)', 'value': 'txt', 'icon': Icons.text_fields},
    {'label': 'PDF (.pdf)', 'value': 'pdf', 'icon': Icons.picture_as_pdf},
    {'label': 'JSON (.json)', 'value': 'json', 'icon': Icons.code},
    {'label': 'CSV (.csv)', 'value': 'csv', 'icon': Icons.table_chart},
  ];

  final List<Map<String, String>> _dateRanges = [
    {'label': 'Toute la conversation', 'value': 'all'},
    {'label': 'Derniers 30 jours', 'value': '30days'},
    {'label': 'Derniers 90 jours', 'value': '90days'},
    {'label': 'Cette année', 'value': 'year'},
  ];

  Future<void> _export() async {
    setState(() => _isExporting = true);

    final provider = Provider.of<ArchiveProvider>(context, listen: false);
    final filePath = await provider.exportConversation(
      conversationId: widget.conversationId,
      format: _selectedFormat,
      includeMedia: _includeMedia,
      includeDate: _includeDate,
      includeTime: _includeTime,
      dateRange: _selectedDateRange,
    );

    setState(() => _isExporting = false);

    if (filePath != null && mounted) {
      _showExportSuccess(filePath);
    }
  }

  void _showExportSuccess(String filePath) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Export terminé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'La conversation a été exportée avec succès',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Share.shareXFiles([XFile(filePath)]);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                    ),
                    child: const Text('Partager', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
          'Exporter la conversation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Conversation info
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat, size: 20, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.conversationName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        'Exportation de la conversation',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Format
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
                  'Format d\'export',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _formats.map((format) {
                    final isSelected = _selectedFormat == format['value'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFormat = format['value']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(format['icon'], size: 14, color: isSelected ? Colors.white : Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              format['label'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Période
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
                  'Période',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._dateRanges.map((range) {
                  final isSelected = _selectedDateRange == range['value'];
                  return RadioListTile<String>(
                    value: range['value'],
                    groupValue: _selectedDateRange,
                    onChanged: (value) => setState(() => _selectedDateRange = value!),
                    title: Text(range['label'], style: const TextStyle(fontSize: 12)),
                    activeColor: const Color(0xFFD4AF37),
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          
          // Options
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Inclure les médias', style: TextStyle(fontSize: 13)),
                  subtitle: const Text('Photos, vidéos et fichiers', style: TextStyle(fontSize: 10)),
                  value: _includeMedia,
                  onChanged: (value) => setState(() => _includeMedia = value),
                  activeColor: const Color(0xFFD4AF37),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Inclure la date', style: TextStyle(fontSize: 13)),
                  value: _includeDate,
                  onChanged: (value) => setState(() => _includeDate = value),
                  activeColor: const Color(0xFFD4AF37),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Inclure l\'heure', style: TextStyle(fontSize: 13)),
                  value: _includeTime,
                  onChanged: (value) => setState(() => _includeTime = value),
                  activeColor: const Color(0xFFD4AF37),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Export button
          Container(
            margin: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _export,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B1B3D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isExporting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Exporter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
