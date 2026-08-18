import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';

abstract class RescueRemoteDataSource {
  Future<List<AnimalReportModel>> getRadarReports();
  Future<bool> acceptMission(String reportId);
  Future<AnimalReportModel?> getOngoingMission();
  Future<bool> completeMission({
    required String reportId,
    required dynamic imageFile, 
    required String resultStatus,
    required String note,
  });
  Future<bool> cancelMission(String reportId);

}

class RescueRemoteDataSourceImpl implements RescueRemoteDataSource {
  final SupabaseClient supabaseClient;

  RescueRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<AnimalReportModel>> getRadarReports() async {
    // Kéo dữ liệu từ View 'radar_reports' vừa tạo
    final response = await supabaseClient
        .from('radar_reports')
        .select()
        .order('created_at', ascending: false);
        
    return (response as List).map((json) => AnimalReportModel.fromJson(json)).toList();
  }

  @override
  Future<bool> acceptMission(String reportId) async {
    // Gọi hàm RPC chốt cứu hộ
    final response = await supabaseClient.rpc('accept_rescue_mission', params: {
      'p_report_id': reportId
    });
    return response as bool;
  }

  @override
    Future<AnimalReportModel?> getOngoingMission() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      print("🔍 [DEBUG] Đang kiểm tra ca dang dở cho User ID: $userId");
      
      var query = supabaseClient
          .from('animal_reports')
          .select()
          .eq('status', 'IN_PROGRESS');
          
      // Lọc theo User nếu có Auth
      if (userId != null) {
        query = query.eq('rescuer_id', userId);
      }

      final response = await query.order('created_at', ascending: false).limit(1);
      
      print("🔍 [debug] Kết quả từ DB trả về: $response");

      if (response.isNotEmpty) {
        print("✅ [debug] ĐÃ TÌM THẤY CA CỨU HỘ DANG DỞ: ${response[0]['animal_type']}");
        final data = Map<String, dynamic>.from(response[0]);
        data['noise_lat'] = 10.77; 
        data['noise_lng'] = 106.65;
        
        return AnimalReportModel.fromJson(data);
      }
      print("❌ [debug] KHÔNG CÓ CA NÀO DANG DỞ.");
      return null;
    } catch (e) {
      print("🔥 [debug] Lỗi kéo ca dang dở: $e");
      return null;
    }
  }
   @override
  Future<bool> completeMission({
    required String reportId,
    required dynamic imageFile, 
    required String resultStatus,
    required String note,
  }) async {
    try {
      // Upload ảnh lên Supabase Storage
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$reportId.$fileExt';
      
      await supabaseClient.storage
          .from('rescue_images')
          .upload('confirmations/$fileName', imageFile);

      // Lấy Link ảnh public
      final imageUrl = supabaseClient.storage.from('rescue_images').getPublicUrl('confirmations/$fileName');

      // Gọi hàm RPC để chốt DB và cộng điểm
      final response = await supabaseClient.rpc('complete_rescue_mission', params: {
        'p_report_id': reportId,
        'p_image_url': imageUrl,
        'p_result': resultStatus,
        'p_note': note
      });
      return response as bool;
    } catch (e) {
      print('🔥 [DEBUG] Lỗi Complete Mission: $e');
      throw Exception('Lỗi hệ thống khi hoàn tất: $e');
    }
  }
 @override
  Future<bool> cancelMission(String reportId) async {
    try {
      final response = await supabaseClient
          .from('animal_reports')
          .update({
            'status': 'OPEN',
            'rescuer_id': null
          })
          .eq('id', reportId)
          .select(); 
      if ((response as List).isEmpty) {
         throw Exception('Lỗi bảo mật RLS: Không có quyền hủy ca này!');
      }
      
      return true;
    } catch (e) {
      print('🔥 [DEBUG] Lỗi Cancel Mission: $e');
      throw Exception('Lỗi hệ thống khi hủy ca: $e');
    }
  }
}