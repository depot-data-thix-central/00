// lib/providers/read_receipt_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/read_receipt_service.dart';
import '../models/read_receipt_models.dart';

class ReadReceiptProvider extends ChangeNotifier {
  late ReadReceiptService _service;
  
  List<ReadReceiptUser> _deliveredUsers = [];
  List<ReadReceiptUser> _readUsers = [];
  bool _isLoading = false;
  
  ReadReceiptProvider() {
    _service = ReadReceiptService(Supabase.instance.client);
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  List<ReadReceiptUser> get deliveredUsers => _deliveredUsers;
  List<ReadReceiptUser> get readUsers => _readUsers;
  bool get isLoading => _isLoading;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> loadReceipts(String messageId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final receipts = await _service.getReceipts(messageId);
      _deliveredUsers = receipts.where((r) => r.isDelivered).toList();
      _readUsers = receipts.where((r) => r.isRead).toList();
    } catch (e) {
      debugPrint('Error loading receipts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> sendPriorityMessage({
    required String conversationId,
    required String content,
    bool requireReadReceipt = true,
  }) async {
    try {
      await _service.sendPriorityMessage(
        conversationId: conversationId,
        content: content,
        requireReadReceipt: requireReadReceipt,
      );
      return true;
    } catch (e) {
      debugPrint('Error sending priority message: $e');
      return false;
    }
  }
  
  Future<void> markAsRead(String messageId) async {
    await _service.markAsRead(messageId);
  }
}
