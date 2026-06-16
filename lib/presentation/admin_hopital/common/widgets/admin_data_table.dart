// 📁 lib/presentation/admin_hopital/common/widgets/admin_data_table.dart

import 'package:flutter/material.dart';

class AdminDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<Map<String, dynamic>> rows;
  final Function(int)? onRowTap;
  final bool selectable;
  final List<int>? selectedRows;
  final Function(List<int>)? onSelectionChanged;
  final int rowsPerPage;
  final bool isLoading;

  const AdminDataTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.selectable = false,
    this.selectedRows,
    this.onSelectionChanged,
    this.rowsPerPage = 10,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Aucune donnée à afficher', style: TextStyle(fontSize: 14)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: PaginatedDataTable(
        columns: widget.columns,
        source: _DataSource(
          rows: widget.rows,
          columns: widget.columns,
          onRowTap: widget.onRowTap,
          selectable: widget.selectable,
          selectedRows: widget.selectedRows ?? [],
          onSelectionChanged: widget.onSelectionChanged,
        ),
        header: const SizedBox.shrink(),
        rowsPerPage: widget.rowsPerPage,
        showCheckboxColumn: widget.selectable,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortColumnIndex = columnIndex;
            _sortAscending = ascending;
            // Tri à implémenter dans le DataSource
          });
        },
        columnSpacing: 16,
        horizontalMargin: 16,
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Map<String, dynamic>> rows;
  final List<DataColumn> columns;
  final Function(int)? onRowTap;
  final bool selectable;
  final List<int> selectedRows;
  final Function(List<int>)? onSelectionChanged;

  _DataSource({
    required this.rows,
    required this.columns,
    this.onRowTap,
    this.selectable = false,
    this.selectedRows = const [],
    this.onSelectionChanged,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final row = rows[index];
    final isSelected = selectedRows.contains(index);

    return DataRow(
      selected: isSelected,
      onSelectChanged: selectable
          ? (selected) {
              final newSelection = List<int>.from(selectedRows);
              if (selected == true) {
                if (!newSelection.contains(index)) newSelection.add(index);
              } else {
                newSelection.remove(index);
              }
              onSelectionChanged?.call(newSelection);
            }
          : null,
      onTap: onRowTap != null ? () => onRowTap!(index) : null,
      cells: columns.map((col) {
        final key = col.label as String? ?? '';
        final value = row[key] ?? '';
        return DataCell(
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => selectedRows.length;
}
