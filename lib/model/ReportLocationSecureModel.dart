class ReportLocationSecureModel {
  final String reportId;
  final double exactLat;
  final double exactLng;
  final double? gpsAccuracy;

  ReportLocationSecureModel({
    required this.reportId,
    required this.exactLat,
    required this.exactLng,
    this.gpsAccuracy,
  });

  factory ReportLocationSecureModel.fromJson(Map<String, dynamic> json) {
    return ReportLocationSecureModel(
      reportId: json['report_id'] ?? '',
      exactLat: (json['exact_lat'] as num).toDouble(),
      exactLng: (json['exact_lng'] as num).toDouble(),
      gpsAccuracy: json['gps_accuracy'] != null ? (json['gps_accuracy'] as num).toDouble() : null,
    );
  }
}