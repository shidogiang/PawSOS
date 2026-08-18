import 'package:paw_sos/features/rescue/domain/repositories/rescue_repository.dart';

class CancelMissionUseCase {
  final RescueRepository repository;

  CancelMissionUseCase(this.repository);

  Future<bool> call(String reportId) async {
    if (reportId.isEmpty) throw Exception("Lỗi ID nhiệm vụ!");
    return await repository.cancelMission(reportId);
  }
}