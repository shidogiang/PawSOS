class AdoptionTrackingModel {
  final String id;
  final String reportId;
  final String adopterId;
  final String? week1Image;
  final String? week2Image;
  final String? week3Image;
  final String? week4Image;
  final String trackingStatus;
  final DateTime createdAt;

  AdoptionTrackingModel({
    required this.id,
    required this.reportId,
    required this.adopterId,
    this.week1Image,
    this.week2Image,
    this.week3Image,
    this.week4Image,
    required this.trackingStatus,
    required this.createdAt,
  });

  factory AdoptionTrackingModel.fromJson(Map<String, dynamic> json) {
    return AdoptionTrackingModel(
      id: json['id'] ?? '',
      reportId: json['report_id'] ?? '',
      adopterId: json['adopter_id'] ?? '',
      week1Image: json['week_1_image'],
      week2Image: json['week_2_image'],
      week3Image: json['week_3_image'],
      week4Image: json['week_4_image'],
      trackingStatus: json['tracking_status'] ?? 'IN_PROGRESS',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}