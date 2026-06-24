import 'enums/account_type.dart';

class AccountModel {
  final String id;
  final String userId;
  final AccountType type;
  final double balance;
  final String currency;
  final bool isActive;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.balance,
    required this.currency,
    required this.isActive,
    required this.createdAt,
  });

  String get typeName => type.displayName;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      userId: json['user_id'],
      type: AccountType.fromApiValue(json['type']),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] ?? 'FC',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.apiValue,
      'balance': balance,
      'currency': currency,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
