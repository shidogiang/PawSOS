import '../repositories/report_repository.dart';

class DeleteReportUseCase {
  final ReportRepository repository;

  DeleteReportUseCase(this.repository);

  Future<void> call(String reportId) async {
    return await repository.deleteReport(reportId);
  }
}