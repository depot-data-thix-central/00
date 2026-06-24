import 'enums/transaction_status.dart';

class TransactionModel {
  final String id;
  final String? fromAccountId;
  final String? toAccountId;
  final double amount;
  final TransactionStatus status;
  final String type; // 'credit' or 'debit'
  final String label;
  final String currency;
  final String reference;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    this.fromAccountId,
    this.toAccountId,
    required this.amount,
    required this.status,
    required this.type,
    required this.label,
    required this.currency,
    required this.reference,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
  bool get isSuccessful => status == TransactionStatus.success;
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  String get formattedDate {
    final now = DateTime.now();
    if (isToday) return "Aujourd'hui, ${_formatTime(createdAt)}";
    return _formatDateTime(createdAt);
  }

  String _formatTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _formatDateTime(DateTime d) => '${d.day}/${d.month}/${d.year} ${_formatTime(d)}';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      fromAccountId: json['from_account_id'],
      toAccountId: json['to_account_id'],
      amount: (json['amount'] as num).toDouble(),
      status: TransactionStatus.fromApiValue(json['status']),
      type: json['type'],
      label: json['label'] ?? _defaultLabel(json),
      currency: json['currency'] ?? 'FC',
      reference: json['reference'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _defaultLabel(Map<String, dynamic> json) {
    if (json['type'] == 'credit') return 'Réception';
    return 'Envoi';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'amount': amount,
      'status': status.apiValue,
      'type': type,
      'label': label,
      'currency': currency,
      'reference': reference,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
