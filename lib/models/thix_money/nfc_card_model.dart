class NfcCardModel {
  final String id;
  final String userId;
  final String cardId;  // identifiant unique de la carte
  final bool isActive;
  final double limitWithoutPin;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  NfcCardModel({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.isActive,
    required this.limitWithoutPin,
    this.lastUsedAt,
    required this.createdAt,
  });

  factory NfcCardModel.fromJson(Map<String, dynamic> json) {
    return NfcCardModel(
      id: json['id'],
      userId: json['user_id'],
      cardId: json['card_id'],
      isActive: json['is_active'] ?? true,
      limitWithoutPin: (json['limit_without_pin'] as num).toDouble(),
      lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_id': cardId,
      'is_active': isActive,
      'limit_without_pin': limitWithoutPin,
      'last_used_at': lastUsedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
