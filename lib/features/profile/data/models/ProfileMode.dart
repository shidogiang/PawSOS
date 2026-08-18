class ProfileModel {
  final String displayName;
  final String joinDate;
  final int trustScore;
  final int rescuedCount;
  final int reportedCount;
  final int adoptedCount;

  ProfileModel({
    required this.displayName,
    required this.joinDate,
    required this.trustScore,
    required this.rescuedCount,
    required this.reportedCount,
    required this.adoptedCount,
  });
}