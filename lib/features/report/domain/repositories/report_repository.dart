import 'dart:io';

import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';

abstract class ReportRepository {
  Future<void> submitReport({
    required File imageFile,
    required double lat,
    required double lng,
    required String animalType,
    required List<String> conditions,
    required String note,
  });
  
  Stream<List<AnimalReportModel>> streamMyReports();
  Future<void> deleteReport(String reportId);
  Future<void> updateReport({
      required String reportId,
      File? newImageFile, // Có thể có ảnh mới hoặc không
      required String animalType,
      required List<String> conditions,
      required String note,
    });
}
