import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';

abstract class RescueRemoteDataSource {
  Future<List<AnimalReportModel>> getRadarReports();
  Future<bool> acceptMission(String reportId);
  Future<AnimalReportModel?> getOngoingMission();
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
    // Gọi hàm RPC chốt đơn cứu hộ
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
      
      print("🔍 [DEBUG] Kết quả từ DB trả về: $response");

      if (response.isNotEmpty) {
        print("✅ [DEBUG] ĐÃ TÌM THẤY CA CỨU HỘ DANG DỞ: ${response[0]['animal_type']}");
        // FIX LỖI NGẦM: Bảng gốc không có noise_lat/lng, ta phải mớm dữ liệu mặc định để Model không bị crash
        final data = Map<String, dynamic>.from(response[0]);
        data['noise_lat'] = 10.77; 
        data['noise_lng'] = 106.65;
        
        return AnimalReportModel.fromJson(data);
      }
      
      print("❌ [DEBUG] KHÔNG CÓ CA NÀO DANG DỞ.");
      return null;
    } catch (e) {
      print("🔥 [DEBUG] Lỗi kéo ca dang dở: $e");
      return null;
    }
  }
}