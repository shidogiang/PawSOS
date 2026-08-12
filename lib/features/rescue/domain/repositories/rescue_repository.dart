import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
abstract class RescueRepository {
  Future<List<AnimalReportModel>> getRadarReports();
  Future<bool> acceptMission(String reportId);
}