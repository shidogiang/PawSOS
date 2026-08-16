import 'package:paw_sos/core/config/app_config.dart';
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

  String ? petName; // Tên con vật (lấy từ bảng animal_reports)
  String ? petImageUrl; // URL ảnh con vật (lấy từ bảng animal_reports

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
  // Trả về tuần hiện tại (từ 1 đến 4)
  int get currentWeek {
    // 1. Tính thời gian đã trôi qua kể từ lúc nhận nuôi
    final timePassed = DateTime.now().difference(createdAt);
    
    // 2. Lấy thời lượng 1 tuần (Thật là 7 ngày, Demo là 2 phút)
    final stageDuration = AppConfig.trackingStageDuration;
    
    // 3. Chia lấy phần nguyên để biết đã qua mấy "tuần" (cộng 1 vì bắt đầu là tuần 1)
    int calculatedWeek = (timePassed.inMilliseconds / stageDuration.inMilliseconds).floor() + 1;
    
    // 4. Giới hạn tối đa là tuần 4
    if (calculatedWeek > 4) return 4;
    return calculatedWeek;
  }

  // Helper kiểm tra xem tuần hiện tại đã được nộp ảnh chưa
  bool isCurrentWeekSubmitted() {
    switch (currentWeek) {
      case 1: return week1Image != null;
      case 2: return week2Image != null;
      case 3: return week3Image != null;
      case 4: return week4Image != null;
      default: return false;
    }
  }

  // Trả về thời gian còn lại (đếm ngược) để mở khóa tuần tiếp theo
  Duration get timeUntilNextWeek {
    final timePassed = DateTime.now().difference(createdAt);
    final stageDuration = AppConfig.trackingStageDuration;
    
    // Tổng thời gian từ lúc tạo đến đầu tuần tiếp theo
    final nextWeekTotalDuration = stageDuration * currentWeek;
    
    return nextWeekTotalDuration - timePassed;
  }
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