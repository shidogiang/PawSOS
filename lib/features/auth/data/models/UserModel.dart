import '../../domain/entities/user_entity.dart';
class UserModel extends UserEntity {
  
  UserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    super.avatarUrl,
    required super.trustScore,
    required super.isKycVerified,
    required super.createdAt, 
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      avatarUrl: json['avatar_url'],
      trustScore: json['trust_score'] ?? 50,
      isKycVerified: json['is_kyc_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'trust_score': trustScore,
      'is_kyc_verified': isKycVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}