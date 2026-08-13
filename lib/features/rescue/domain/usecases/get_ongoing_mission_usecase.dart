import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import '../repositories/rescue_repository.dart';

class CheckOngoingMissionUseCase {
  final RescueRepository repository;

  CheckOngoingMissionUseCase(this.repository);

  Future<AnimalReportModel?> call() async {
    return await repository.getOngoingMission();
  }
}