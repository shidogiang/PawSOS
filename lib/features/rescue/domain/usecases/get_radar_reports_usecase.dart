import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import '../repositories/rescue_repository.dart';

class GetRadarReportsUseCase {
  final RescueRepository repository;

  GetRadarReportsUseCase(this.repository);

  Future<List<AnimalReportModel>> call() async {
    return await repository.getRadarReports();
  }
}