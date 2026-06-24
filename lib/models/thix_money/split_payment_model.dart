class SplitPaymentModel {
  final String id;
  final String code;
  final double totalAmount;
  final double remainingAmount;
  final String creatorId;
  final String merchantId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isCompleted;

  SplitPaymentModel({
    required this.id,
    required this.code,
    required this.totalAmount,
    required this.remainingAmount,
    required this.creatorId,
    required this.merchantId,
    required this.createdAt,
    required this.expiresAt,
    required this.isCompleted,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  double get completedAmount => totalAmount - remainingAmount;

  factory SplitPaymentModel.fromJson(Map<String, dynamic> json) {
    return SplitPaymentModel(
      id: json['id'],
      code: json['code'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      creatorId: json['creator_id'],
      merchantId: json['merchant_id'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'creator_id': creatorId,
      'merchant_id': merchantId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}
