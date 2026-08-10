class AnimalReportModel {
  final String id;
  final String reporterId;
  final String? rescuerId;
  final String animalType;
  final String status; // 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CANCELLED'
  final String description;
  final String imageUrl;
  final double? noiseLat;
  final double? noiseLng;
  final DateTime createdAt;

  AnimalReportModel({
    required this.id,
    required this.reporterId,
    this.rescuerId,
    required this.animalType,
    required this.status,
    required this.description,
    required this.imageUrl,
    this.noiseLat,
    this.noiseLng,
    required this.createdAt,
  });

  // GETTER CHO UI 
  String get title => animalType;
  
  // Thực tế sau này sẽ dùng thư viện geolocator tính khoảng cách từ (noiseLat, noiseLng) tới GPS của User
  String get distance => '~ 2.5 km'; 
  
  // Tính toán thời gian thực tế so với lúc báo cáo
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  factory AnimalReportModel.fromJson(Map<String, dynamic> json) {
    return AnimalReportModel(
      id: json['id'] ?? '',
      reporterId: json['reporter_id'] ?? '',
      rescuerId: json['rescuer_id'],
      animalType: json['animal_type'] ?? 'Không rõ',
      status: json['status'] ?? 'OPEN',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      //  PostGIS: Trả về qua API sẽ được alias thành lat/lng 
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
        description: 'Mèo con kêu trên mái nhà tôn từ sáng, trời đang nắng gắt.',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=600&auto=format&fit=crop',
        status: 'OPEN',
        noiseLat: 10.772622, noiseLng: 106.650172,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}