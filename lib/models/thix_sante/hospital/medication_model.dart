// 📁 lib/models/thix_sante/hospital/medication_model.dart

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String? form; // Comprimé, Gélule, etc.
  final int quantity;
  final int? threshold;
  final double? price;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String status; // active, inactive, expired
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    this.form,
    required this.quantity,
    this.threshold,
    this.price,
    this.batchNumber,
    this.expiryDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      form: json['form'],
      quantity: json['quantity'] ?? 0,
      threshold: json['threshold'],
      price: json['price']?.toDouble(),
      batchNumber: json['batch_number'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'form': form,
      'quantity': quantity,
      'threshold': threshold,
      'price': price,
      'batch_number': batchNumber,
      'expiry_date': expiryDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MedicationModel copyWith({
    int? quantity,
    String? status,
  }) {
    return MedicationModel(
      id: id,
      name: name,
      dosage: dosage,
      form: form,
      quantity: quantity ?? this.quantity,
      threshold: threshold,
      price: price,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
