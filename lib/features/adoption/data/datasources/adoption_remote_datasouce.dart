import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/AdoptionTrackingModel.dart';
abstract class AdoptionRemoteDataSource {
  Future<List<AdoptionTrackingModel>> getMyTrackings();
  Future<bool> submitWeeklyImage({required String trackingId, required int week, required dynamic imageFile});
  Future<Map<String, int>> getActivityStats(); // THÊM HÀM NÀY

}

class AdoptionRemoteDataSourceImpl implements AdoptionRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdoptionRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<AdoptionTrackingModel>> getMyTrackings() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception("Vui lòng đăng nhập để xem tiến độ nhận nuôi.");

    // Lấy dữ liệu tracking, JOIN với bảng animal_reports để lấy luôn tên và ảnh con vật
    final response = await supabaseClient
        .from('adoption_tracking')
        .select('*, animal_reports(animal_type, image_url)')
        .eq('adopter_id', userId)
        .order('created_at', ascending: false);

    // Chuyển Map thành Model
    return (response as List).map((json) {
      final model = AdoptionTrackingModel.fromJson(json);
      // Gắn thêm data Join (Thủ thuật nhét data vào model có sẵn)
      model.petName = json['animal_reports']['animal_type'];
      model.petImageUrl = json['animal_reports']['image_url'];
      return model;
    }).toList();
  }

  @override
  Future<bool> submitWeeklyImage({required String trackingId, required int week, required dynamic imageFile}) async {
    try {
      // 1. Upload ảnh lên Storage (Bucket: adoption_images)
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_week$week.$fileExt';
      
      await supabaseClient.storage
          .from('adoption_images')
          .upload('$trackingId/$fileName', imageFile);

      final imageUrl = supabaseClient.storage.from('adoption_images').getPublicUrl('$trackingId/$fileName');

      // 2. Cập nhật URL ảnh vào cột tương ứng (week_1_image, week_2_image...)
      final columnName = 'week_${week}_image';
      
      await supabaseClient
          .from('adoption_tracking')
          .update({columnName: imageUrl})
          .eq('id', trackingId);

      // (Tùy chọn) Chốt trạng thái COMPLETED nếu đã nộp đủ tuần 4
      if (week == 4) {
         await supabaseClient.from('adoption_tracking').update({'tracking_status': 'COMPLETED'}).eq('id', trackingId);
      }

      return true;
    } catch (e) {
      print('🔥 [DEBUG] Lỗi Upload Ảnh Tracking: $e');
      throw Exception('Lỗi nộp ảnh tuần $week: $e');
    }
  }
  @override
  Future<Map<String, int>> getActivityStats() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return {'rescued': 0, 'reported': 0};

    try {
      // Đếm số ca đã cứu thành công (RESOLVED)
      final rescued = await supabaseClient.from('animal_reports').select('id').eq('rescuer_id', userId).eq('status', 'RESOLVED');
      
      // Đếm số ca đã báo cáo (Mọi status)
      final reported = await supabaseClient.from('animal_reports').select('id').eq('reporter_id', userId);

      return {
        'rescued': (rescued as List).length,
        'reported': (reported as List).length,
      };
    } catch (e) {
      print('🔥 [DEBUG] Lỗi lấy thống kê: $e');
      return {'rescued': 0, 'reported': 0};
    }
  }
}