// 📁 lib/presentation/admin_hopital/advanced_clinics/widgets/protocol_decision_tree.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProtocolNode {
  final String id;
  final String question;
  final String? description;
  final List<ProtocolNode> children;
  final String? action;
  final bool isLeaf;

  ProtocolNode({
    required this.id,
    required this.question,
    this.description,
    this.children = const [],
    this.action,
    this.isLeaf = false,
  });
}

class ProtocolDecisionTree extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final String protocolType;
  final Function(Map<String, dynamic>) onComplete;

  const ProtocolDecisionTree({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.protocolType,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<ProtocolDecisionTree> createState() => _ProtocolDecisionTreeState();
}

class _ProtocolDecisionTreeState extends ConsumerState<ProtocolDecisionTree> {
  ProtocolNode? _currentNode;
  List<ProtocolNode> _path = [];
  List<String> _selectedAnswers = [];
  bool _isComplete = false;
  Map<String, dynamic> _result = {};

  // Arbre de décision pour le bilan septique
  final ProtocolNode _rootNode = ProtocolNode(
    id: 'root',
    question: 'Signes de sepsis ?',
    description: 'Évaluer les critères de SIRS',
    children: [
      ProtocolNode(
        id: 'sirs_yes',
        question: 'Présence de fièvre > 38.5°C ou hypothermie < 36°C ?',
        children: [
          ProtocolNode(
            id: 'sirs_2',
            question: 'FC > 90/min ou FR > 20/min ?',
            children: [
              ProtocolNode(
                id: 'sepsis_suspected',
                question: 'Diagnostic: Sepsis suspecté',
                description: 'Réaliser bilan septique complet (hémocultures, CRP, PCT, radiographie)',
                isLeaf: true,
                action: 'Bilan septique',
              ),
            ],
          ),
          ProtocolNode(
            id: 'sirs_3',
            question: 'GB > 12000/mm³ ou < 4000/mm³ ?',
            children: [
              ProtocolNode(
                id: 'sepsis_confirmed',
                question: 'Diagnostic: Sepsis confirmé',
                description: 'Hospitalisation en soins intensifs, antibiothérapie large spectre, monitorage continu',
                isLeaf: true,
                action: 'Sepsis confirmé',
              ),
            ],
          ),
        ],
      ),
      ProtocolNode(
        id: 'sirs_no',
        question: 'Pression artérielle systolique < 90 mmHg ?',
        children: [
          ProtocolNode(
            id: 'shock_risk',
            question: 'Diagnostic: Risque de choc septique',
            description: 'Alertes, remplissage vasculaire, transfert en réanimation',
            isLeaf: true,
            action: 'Choc septique suspecté',
          ),
        ],
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _currentNode = _rootNode;
    _path = [_rootNode];
  }

  void _selectPath(int index) {
    setState(() {
      final node = _currentNode!.children[index];
      _currentNode = node;
      _path.add(node);
      _selectedAnswers.add(node.question);
      if (node.isLeaf) {
        _isComplete = true;
        _result = {
          'protocolType': widget.protocolType,
          'path': _path.map((p) => p.question).join(' -> '),
          'action': node.action,
          'description': node.description,
          'timestamp': DateTime.now(),
        };
        widget.onComplete(_result);
      }
    });
  }

  void _goBack() {
    if (_path.length > 1) {
      setState(() {
        _path.removeLast();
        _selectedAnswers.removeLast();
        _currentNode = _path.last;
        _isComplete = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _currentNode = _rootNode;
      _path = [_rootNode];
      _selectedAnswers = [];
      _isComplete = false;
      _result = {};
    });
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
              const Icon(Icons.account_tree, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Arbre décisionnel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.protocolType,
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chemin parcouru
          if (_path.length > 1)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chemin:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  ..._path.skip(1).map((node) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                        Expanded(
                          child: Text(
                            node.question,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Question courante
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentNode!.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                if (_currentNode!.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _currentNode!.description!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Options
          if (!_isComplete)
            Column(
              children: _currentNode!.children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () => _selectPath(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child.question,
                                style: const TextStyle(fontSize: 13, color: Colors.black),
                              ),
                              if (child.description != null)
                                Text(
                                  child.description!,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          // Résultat
          if (_isComplete) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Décision prise',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result['action'] ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _result['description'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              if (_path.length > 1 && !_isComplete)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Retour', style: TextStyle(fontSize: 13)),
                  ),
                ),
              if (_isComplete) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Nouveau protocole', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
