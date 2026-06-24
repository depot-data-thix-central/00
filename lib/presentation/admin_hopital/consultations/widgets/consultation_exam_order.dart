// 📁 lib/presentation/admin_hopital/consultations/widgets/consultation_exam_order.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_form_field.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class ExamOrderItem {
  final String examType;
  final String? details;
  final String priority;
  final String? notes;

  ExamOrderItem({
    required this.examType,
    this.details,
    this.priority = 'normal',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'examType': examType,
      'details': details,
      'priority': priority,
      'notes': notes,
    };
  }
}

class ConsultationExamOrder extends StatefulWidget {
  final Function(List<ExamOrderItem>) onSave;
  final List<ExamOrderItem>? initialOrders;

  const ConsultationExamOrder({
    Key? key,
    required this.onSave,
    this.initialOrders,
  }) : super(key: key);

  @override
  State<ConsultationExamOrder> createState() => _ConsultationExamOrderState();
}

class _ConsultationExamOrderState extends State<ConsultationExamOrder> {
  final List<ExamOrderItem> _orders = [];
  final List<String> _examTypes = [
    'Biologie', 'Hématologie', 'Biochimie', 'Microbiologie',
    'Radiologie', 'Échographie', 'Scanner', 'IRM',
    'Électrocardiogramme', 'Échocardiographie', 'Holter',
    'Endoscopie', 'Coloscopie', 'Bronchoscopie',
    'Biopsie', 'Cytologie',
    'Autre'
  ];
  final List<String> _priorities = ['normal', 'urgent', 'très urgent'];

  String _selectedExam = 'Biologie';
  String _priority = 'normal';
  final _detailsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialOrders != null) {
      _orders.addAll(widget.initialOrders!);
    }
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addOrder() {
    setState(() {
      _orders.add(ExamOrderItem(
        examType: _selectedExam,
        details: _detailsCtrl.text.isNotEmpty ? _detailsCtrl.text : null,
        priority: _priority,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      ));
      _detailsCtrl.clear();
      _notesCtrl.clear();
    });
  }

  void _removeOrder(int index) {
    setState(() {
      _orders.removeAt(index);
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.orange;
      case 'très urgent':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'très urgent':
        return 'Très urgent';
      default:
        return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Prescription d\'examens',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Formulaire d'ajout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedExam,
                        items: _examTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedExam = v ?? _selectedExam),
                        decoration: InputDecoration(
                          labelText: 'Type d\'examen',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _priority,
                        items: _priorities.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getPriorityColor(p),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(_getPriorityLabel(p), style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _priority = v ?? _priority),
                        decoration: InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AdminFormField(
                  label: 'Détails (optionnel)',
                  controller: _detailsCtrl,
                  hint: 'Bilan hépatique complet, etc.',
                ),
                const SizedBox(height: 10),
                AdminFormField(
                  label: 'Notes (optionnel)',
                  controller: _notesCtrl,
                  hint: 'Instructions supplémentaires',
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                AdminGradientButton(
                  text: 'Ajouter l\'examen',
                  onPressed: _addOrder,
                  icon: Icons.add,
                  height: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Liste des examens
          if (_orders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucun examen prescrit',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: _orders.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = _getPriorityColor(item.priority);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.science, size: 16, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.examType,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPriorityLabel(item.priority),
                              style: TextStyle(fontSize: 11, color: color),
                            ),
                            if (item.details != null)
                              Text(
                                item.details!,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            if (item.notes != null)
                              Text(
                                '📝 ${item.notes!}',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () => _removeOrder(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          if (_orders.isNotEmpty)
            AdminGradientButton(
              text: 'Enregistrer les examens',
              onPressed: () => widget.onSave(_orders),
              icon: Icons.save,
              height: 40,
            ),
        ],
      ),
    );
  }
}
