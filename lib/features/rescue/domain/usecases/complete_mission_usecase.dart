import '../repositories/rescue_repository.dart';

class CompleteMissionUseCase {
  final RescueRepository repository;

  CompleteMissionUseCase(this.repository);

  Future<bool> call(String reportId, dynamic imageFile, String resultStatus, String note) async {
    if (reportId.isEmpty || imageFile == null) throw Exception("Thiếu thông tin hình ảnh xác nhận!");
    return await repository.completeMission(reportId, imageFile, resultStatus, note);
  }
}