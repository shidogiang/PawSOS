class ReportStatusHistoryModel {
  final String id;
  final String reportId;
  final String? changedBy;
  final String? oldStatus;
  final String? newStatus;
  final String? changeReason;
  final DateTime createdAt;

  ReportStatusHistoryModel({
    required this.id,
    required this.reportId,
    this.changedBy,
    this.oldStatus,
    this.newStatus,
    this.changeReason,
    required this.createdAt,
  });

  factory ReportStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReportStatusHistoryModel(
      id: json['id'] ?? '',
      reportId: json['report_id'] ?? '',
      changedBy: json['changed_by'],
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
      changeReason: json['change_reason'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}