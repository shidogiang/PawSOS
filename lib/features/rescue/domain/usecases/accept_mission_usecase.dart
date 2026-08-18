import '../repositories/rescue_repository.dart';

class AcceptMissionUseCase {
  final RescueRepository repository;

  AcceptMissionUseCase(this.repository);

  // Trust Score của user trước khi cho nhận nhiệm vụ.
  Future<bool> call(String reportId) async {
    if (reportId.isEmpty) return false;
    return await repository.acceptMission(reportId);
  }
}