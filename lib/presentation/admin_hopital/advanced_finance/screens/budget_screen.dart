// 📁 lib/presentation/admin_hopital/advanced_finance/screens/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/budget_tracker.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _isLoading = true;

  // Données mockées
  final Map<String, dynamic> _budgetData = {
    'totalBudget': 250000.0,
    'totalSpent': 185000.0,
    'departments': [
      {'name': 'Cardiologie', 'budget': 45000.0, 'spent': 38000.0},
      {'name': 'Pédiatrie', 'budget': 35000.0, 'spent': 28000.0},
      {'name': 'Orthopédie', 'budget': 40000.0, 'spent': 32000.0},
      {'name': 'Radiologie', 'budget': 30000.0, 'spent': 25000.0},
      {'name': 'Urgences', 'budget': 55000.0, 'spent': 52000.0},
      {'name': 'Bloc opératoire', 'budget': 45000.0, 'spent': 38000.0},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  void _onDepartmentTap(String departmentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails du budget pour $departmentName'),
        backgroundColor: Colors.blue,
      ),
    );
    // Naviguer vers les détails du service
    // context.push('/admin/finance/budget/department/$departmentName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi budgétaire'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Créer un budget'), backgroundColor: Colors.blue),
              );
            },
            tooltip: 'Créer un budget',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement du budget...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BudgetTracker(
                budgetData: _budgetData,
                onDepartmentTap: _onDepartmentTap,
              ),
              const SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: AdminGradientButton(
                      text: 'Rapport budget',
                      onPressed: () {
                        context.push('/admin/finance/budget/report');
                      },
                      icon: Icons.assessment,
                      gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminGradientButton(
                      text: 'Ajuster',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajustement budgétaire'), backgroundColor: Colors.orange),
                        );
                      },
                      icon: Icons.edit,
                      gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
