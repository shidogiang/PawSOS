import '../repositories/rescue_repository.dart';

class AcceptMissionUseCase {
  final RescueRepository repository;

  AcceptMissionUseCase(this.repository);

  // Hàm call nhận tham số đầu vào. Tương lai có thể check thêm 
  // Trust Score của user trước khi cho nhận nhiệm vụ.
  Future<bool> call(String reportId) async {
    if (reportId.isEmpty) return false;
    return await repository.acceptMission(reportId);
  }
}