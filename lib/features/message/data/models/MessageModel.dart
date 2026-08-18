class ChatMessageModel {
  final String id;
  final String reportId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.reportId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      reportId: json['report_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}