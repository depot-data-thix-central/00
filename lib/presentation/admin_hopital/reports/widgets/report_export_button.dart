// 📁 lib/presentation/admin_hopital/reports/widgets/report_export_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class ReportExportButton extends ConsumerStatefulWidget {
  final Function(String) onExport;
  final bool isLoading;

  const ReportExportButton({
    Key? key,
    required this.onExport,
    this.isLoading = false,
  }) : super(key: key);

  @override
  ConsumerState<ReportExportButton> createState() => _ReportExportButtonState();
}

class _ReportExportButtonState extends ConsumerState<ReportExportButton> {
  String _selectedFormat = 'CSV';
  final List<String> _formats = ['CSV', 'Excel', 'PDF', 'JSON'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Text(
            'Exporter en',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButton<String>(
              value: _selectedFormat,
              items: _formats.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(
                    format,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selectedFormat == format ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedFormat = v ?? 'CSV'),
              underline: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 8),
          AdminGradientButton(
            text: widget.isLoading ? 'Export...' : 'Exporter',
            onPressed: widget.isLoading ? null : () => widget.onExport(_selectedFormat),
            icon: widget.isLoading ? null : Icons.download,
            height: 38,
            width: 120,
            gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
          ),
        ],
      ),
    );
  }

  // Widget statique pour un bouton d'export simple
  static Widget simpleButton({
    required VoidCallback onPressed,
    bool isLoading = false,
    String label = 'Exporter',
  }) {
    return AdminGradientButton(
      text: isLoading ? 'Export...' : label,
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? null : Icons.download,
      height: 38,
      width: 120,
      gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
    );
  }

  // Widget pour un menu d'export avec options de format
  static Widget withFormatMenu({
    required Function(String) onExport,
    bool isLoading = false,
    List<String>? formats,
  }) {
    return ReportExportButton(
      onExport: onExport,
      isLoading: isLoading,
    );
  }
}
