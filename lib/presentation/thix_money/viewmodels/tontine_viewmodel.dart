import 'package:flutter/material.dart';
import '../../services/thix_money/tontine_service.dart';
import '../../models/thix_money/tontine_model.dart';

class TontineViewmodel extends ChangeNotifier {
  final TontineService _tontineService = TontineService();
  List<Tontine> _tontines = [];
  String newTontineName = '';
  double newTontineContribution = 0;

  List<Tontine> get tontines => _tontines;

  Future<void> loadTontines() async {
    _tontines = await _tontineService.getTontines();
    notifyListeners();
  }

  Future<void> createTontine() async {
    if (newTontineName.isEmpty || newTontineContribution <= 0) return;
    await _tontineService.createTontine(newTontineName, newTontineContribution);
    await loadTontines();
  }

  Future<void> payContribution(String tontineId) async {
    await _tontineService.payContribution(tontineId);
    await loadTontines();
  }
}
