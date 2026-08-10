class UserEntity {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final int trustScore;
  final bool isKycVerified;
  final DateTime createdAt; 

  UserEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    required this.trustScore,
    required this.isKycVerified,
    required this.createdAt, 
  });
}