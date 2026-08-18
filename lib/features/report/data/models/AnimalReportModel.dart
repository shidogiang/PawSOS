import '../../domain/entities/animal_report_entity.dart';

// Parse JSON từ Supabase
class AnimalReportModel extends AnimalReportEntity {
  const AnimalReportModel({
    required super.id,
    required super.reporterId,
    super.rescuerId,
    required super.animalType,
    required super.conditions,
    required super.status,
    required super.description,
    required super.imageUrl,
    super.noiseLat,
    super.noiseLng,
    required super.createdAt,
  });

  factory AnimalReportModel.fromJson(Map<String, dynamic> json) {
    return AnimalReportModel(
      id: json['id'] ?? '',
      reporterId: json['reporter_id'] ?? '',
      rescuerId: json['rescuer_id'],
      animalType: json['animal_type'] ?? 'Không rõ',
      // Ép kiểu dynamic list thành List<String> cho cột conditions
      conditions: json['conditions'] != null 
          ? List<String>.from(json['conditions']) 
          : [],
      status: json['status'] ?? 'OPEN',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      noiseLat: json['noise_lat'] != null ? (json['noise_lat'] as num).toDouble() : null,
      noiseLng: json['noise_lng'] != null ? (json['noise_lng'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}