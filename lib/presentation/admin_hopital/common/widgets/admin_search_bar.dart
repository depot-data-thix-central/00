// 📁 lib/presentation/admin_hopital/common/widgets/admin_search_bar.dart

import 'package:flutter/material.dart';

class AdminSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? hintText;
  final TextEditingController? controller;
  final List<String>? suggestions;
  final bool autofocus;

  const AdminSearchBar({
    Key? key,
    required this.onSearch,
    this.hintText,
    this.controller,
    this.suggestions,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: (value) {
                widget.onSearch(value);
              },
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Rechercher...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade500),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearch('');
                          _focusNode.requestFocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
