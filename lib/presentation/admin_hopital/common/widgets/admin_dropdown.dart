// 📁 lib/presentation/admin_hopital/common/widgets/admin_dropdown.dart

import 'package:flutter/material.dart';

class AdminDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final bool isSearchable;

  const AdminDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.isSearchable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSearchable) {
      return _SearchableDropdown<T>(
        label: label,
        value: value,
        items: items,
        onChanged: onChanged,
        hint: hint,
      );
    }
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}

class _SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  const _SearchableDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  State<_SearchableDropdown<T>> createState() => __SearchableDropdownState<T>();
}

class __SearchableDropdownState<T> extends State<_SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<DropdownMenuItem<T>> _filteredItems;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchTerm = value.toLowerCase();
                    _filteredItems = widget.items.where((item) {
                      final childText = item.child is Text
                          ? (item.child as Text).data?.toLowerCase() ?? ''
                          : '';
                      return childText.contains(_searchTerm);
                    }).toList();
                  });
                },
              ),
              if (_filteredItems.isNotEmpty)
                DropdownButton<T>(
                  value: widget.value,
                  items: _filteredItems,
                  onChanged: widget.onChanged,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: Text(widget.hint ?? 'Sélectionner...'),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Aucun résultat', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
