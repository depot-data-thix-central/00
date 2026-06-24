// 📁 lib/presentation/admin_hopital/common/widgets/admin_date_picker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDatePicker extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final bool includeTime;

  const AdminDatePicker({
    Key? key,
    required this.label,
    this.selectedDate,
    required this.onDateSelected,
    this.includeTime = false,
  }) : super(key: key);

  @override
  State<AdminDatePicker> createState() => _AdminDatePickerState();
}

class _AdminDatePickerState extends State<AdminDatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? widget.includeTime
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!)
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : widget.label,
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDate != null ? Colors.black : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    if (widget.includeTime) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
      );
      if (time != null) {
        final combined = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() => _selectedDate = combined);
        widget.onDateSelected(combined);
      }
    } else {
      setState(() => _selectedDate = picked);
      widget.onDateSelected(picked);
    }
  }
}
