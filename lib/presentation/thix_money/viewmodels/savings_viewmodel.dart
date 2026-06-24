import 'package:flutter/material.dart';
import '../../services/thix_money/savings_service.dart';
import '../../models/thix_money/saving_goal.dart';

class SavingsViewmodel extends ChangeNotifier {
  final SavingsService _savingsService = SavingsService();
  double _savingsBalance = 0;
  List<SavingGoal> _savingGoals = [];
  double amountToSave = 0;

  double get savingsBalance => _savingsBalance;
  List<SavingGoal> get savingGoals => _savingGoals;

  Future<void> loadSavingsData() async {
    final balance = await _savingsService.getSavingsBalance();
    _savingsBalance = balance;
    _savingGoals = await _savingsService.getSavingGoals();
    notifyListeners();
  }

  Future<void> saveMoney() async {
    if (amountToSave <= 0) return;
    await _savingsService.saveMoney(amountToSave);
    await loadSavingsData();
  }
}
