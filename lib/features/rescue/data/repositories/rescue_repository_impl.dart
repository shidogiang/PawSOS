import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import '../../domain/repositories/rescue_repository.dart';
import '../datasources/rescue_remote_data_source.dart';

class RescueRepositoryImpl implements RescueRepository {
  final RescueRemoteDataSource remoteDataSource;

  RescueRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AnimalReportModel>> getRadarReports() async {
    // Gọi xuống DataSource
    return await remoteDataSource.getRadarReports();
  }

  @override
  Future<bool> acceptMission(String reportId) async {
    // Gọi xuống DataSource
    return await remoteDataSource.acceptMission(reportId);
  }

  @override
  Future<AnimalReportModel?> getOngoingMission() async {
    return await remoteDataSource.getOngoingMission();
  }

  @override
  Future<bool> completeMission(String reportId, dynamic photoFile, String resultStatus, String note) async {
    return await remoteDataSource.completeMission(
      reportId: reportId,
      imageFile: photoFile,
      resultStatus: resultStatus,
      note: note
    );
  }
}