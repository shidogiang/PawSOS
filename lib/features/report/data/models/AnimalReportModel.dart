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

  // Test data 
  static List<AnimalReportModel> getMockData() {
    return [
      AnimalReportModel(
        id: 'rpt_001',
        reporterId: 'user_1',
        animalType: 'Chó cỏ - Bị xe đụng',
        conditions: const ['🩸 Bị thương'],
        description: 'Bé nằm thoi thóp ven đường, gãy chân sau. Mong ai đó đến nhanh.',
        imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=600&auto=format&fit=crop',
        status: 'OPEN',
        noiseLat: 10.762622, noiseLng: 106.660172,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      AnimalReportModel(
        id: 'rpt_002',
        reporterId: 'user_2',
        animalType: 'Mèo hoang - Mắc kẹt',
        conditions: const ['⛓️ Mắc kẹt', '🥺 Suy kiệt / Đói'],
        description: 'Mèo con kêu trên mái nhà tôn từ sáng, trời đang nắng gắt.',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=600&auto=format&fit=crop',
        status: 'OPEN',
        noiseLat: 10.772622, noiseLng: 106.650172,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}