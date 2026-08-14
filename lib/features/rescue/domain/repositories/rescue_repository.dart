import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
abstract class RescueRepository {
  Future<List<AnimalReportModel>> getRadarReports();
  Future<bool> acceptMission(String reportId);
  Future<AnimalReportModel?> getOngoingMission();
  Future<bool> completeMission(String reportId, dynamic photoFile, String resultStatus, String note); // Thêm phương thức hoàn tất ca cứu hộ với ảnh minh chứng
}