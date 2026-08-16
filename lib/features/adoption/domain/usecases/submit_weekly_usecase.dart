import '../repositories/adoption_repository.dart';
class SubmitWeeklyImageUseCase {
  final AdoptionRepository repository;
  SubmitWeeklyImageUseCase(this.repository);

  Future<bool> call(String trackingId, int week, dynamic imageFile) async {
    if (trackingId.isEmpty || imageFile == null || week < 1 || week > 4) {
      throw Exception("Dữ liệu nộp ảnh không hợp lệ!");
    }
    return await repository.submitWeeklyImage(trackingId, week, imageFile);
  }
}