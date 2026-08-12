import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';

abstract class RescueRemoteDataSource {
  Future<List<AnimalReportModel>> getRadarReports();
  Future<bool> acceptMission(String reportId);
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
}