import 'dart:io';

abstract class ReportRepository {
  Future<void> submitReport({
    required File imageFile,
    required double lat,
    required double lng,
    required String animalType,
    required List<String> conditions,
    required String note,
  });
}