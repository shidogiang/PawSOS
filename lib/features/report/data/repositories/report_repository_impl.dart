import 'dart:io';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitReport({
    required File imageFile,
    required double lat,
    required double lng,
    required String animalType,
    required List<String> conditions,
    required String note,
  }) async {
    // Repository đóng vai trò kiểm tra kết nối mạng, xử lý cach
    // Ở đây ta gọi thẳng xuống DataSource
    await remoteDataSource.submitReport(
      imageFile: imageFile,
      lat: lat,
      lng: lng,
      animalType: animalType,
      conditions: conditions,
      note: note,
    );
  }
}