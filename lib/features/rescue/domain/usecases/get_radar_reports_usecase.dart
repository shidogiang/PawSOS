import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import '../repositories/rescue_repository.dart';

class GetRadarReportsUseCase {
  final RescueRepository repository;

  GetRadarReportsUseCase(this.repository);

  // Hàm call chính của UseCase. Tương lai nếu có logic lọc, sort theo GPS 
  // thì sẽ viết hết thuật toán vào đây chứ không viết vào BLoC
  Future<List<AnimalReportModel>> call() async {
    return await repository.getRadarReports();
  }
}