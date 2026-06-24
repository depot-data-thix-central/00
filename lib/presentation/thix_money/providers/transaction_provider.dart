import 'package:flutter/material.dart';
import '../../services/thix_money/transaction_service.dart';
import '../../models/thix_money/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String _filterType = 'all'; // 'all', 'sent', 'received'
  String _searchQuery = '';

  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String get filterType => _filterType;

  List<TransactionModel> get _filteredTransactions {
    var list = _transactions;
    if (_filterType == 'sent') {
      list = list.where((t) => t.type == 'debit').toList();
    } else if (_filterType == 'received') {
      list = list.where((t) => t.type == 'credit').toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) => t.label.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  Future<void> loadAllTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _transactionService.getAllTransactions();
    } catch (e) {
      debugPrint('TransactionProvider loadAllTransactions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _filterType = 'all';
    _searchQuery = '';
    notifyListeners();
  }
}
