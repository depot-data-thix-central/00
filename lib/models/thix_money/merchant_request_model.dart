import 'enums/merchant_status.dart';

class MerchantRequestModel {
  final String id;
  final String userId;
  final String businessName;
  final String businessType;
  final String? taxId;
  final String phone;
  final MerchantStatus status;
  final String? rejectionReason;
  final DateTime createdAt;

  MerchantRequestModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    this.taxId,
    required this.phone,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory MerchantRequestModel.fromJson(Map<String, dynamic> json) {
    return MerchantRequestModel(
      id: json['id'],
      userId: json['user_id'],
      businessName: json['business_name'],
      businessType: json['business_type'],
      taxId: json['tax_id'],
      phone: json['phone'],
      status: MerchantStatus.fromApiValue(json['status']),
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_type': businessType,
      'tax_id': taxId,
      'phone': phone,
      'status': status.apiValue,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
