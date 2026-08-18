
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import '../repositories/report_repository.dart';

class StreamMyReportsUseCase {
  final ReportRepository repository;
  StreamMyReportsUseCase(this.repository);

  Stream<List<AnimalReportModel>> call() {
    return repository.streamMyReports();
  }
}