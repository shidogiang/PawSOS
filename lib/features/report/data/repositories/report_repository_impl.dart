import 'dart:io';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/report/domain/repositories/report_repository.dart';

import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitReport({
    required File imageFile, required double lat, required double lng,
    required String animalType, required List<String> conditions, required String note,
  }) async {
    await remoteDataSource.submitReport(
      imageFile: imageFile, lat: lat, lng: lng,
      animalType: animalType, conditions: conditions, note: note,
    );
  }

  @override
  Stream<List<AnimalReportModel>> streamMyReports() {
    return remoteDataSource.streamMyReports();
  }
  @override
  Future<void> deleteReport(String reportId) async {
    await remoteDataSource.deleteReport(reportId);
  }

  @override
  Future<void> updateReport({
    required String reportId, File? newImageFile,
    required String animalType, required List<String> conditions, required String note,
  }) async {
    await remoteDataSource.updateReport(
      reportId: reportId, newImageFile: newImageFile,
      animalType: animalType, conditions: conditions, note: note,
    );
  }
}