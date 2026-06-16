
// 📁 lib/models/thix_sante/hospital/patient_model.dart

class PatientModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String? emergencyContact;
  final String hospitalId;
  final String? thixId;
  final String gender;
  final String? bloodType;
  final DateTime birthDate;
  final List<String>? allergies;
  final String status; // active, inactive, admitted
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.emergencyContact,
    required this.hospitalId,
    this.thixId,
    required this.gender,
    this.bloodType,
    required this.birthDate,
    this.allergies,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      emergencyContact: json['emergency_contact'],
      hospitalId: json['hospital_id'] ?? '',
      thixId: json['thix_id'],
      gender: json['gender'] ?? 'Non défini',
      bloodType: json['blood_type'],
      birthDate: DateTime.parse(json['birth_date']),
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'emergency_contact': emergencyContact,
      'hospital_id': hospitalId,
      'thix_id': thixId,
      'gender': gender,
      'blood_type': bloodType,
      'birth_date': birthDate.toIso8601String(),
      'allergies': allergies,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PatientModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? hospitalId,
    String? thixId,
    String? gender,
    String? bloodType,
    DateTime? birthDate,
    List<String>? allergies,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      hospitalId: hospitalId ?? this.hospitalId,
      thixId: thixId ?? this.thixId,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      birthDate: birthDate ?? this.birthDate,
      allergies: allergies ?? this.allergies,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
