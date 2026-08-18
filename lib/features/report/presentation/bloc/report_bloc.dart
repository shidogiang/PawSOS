import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/report/domain/usecases/delete_report_usecase.dart';
import 'package:paw_sos/features/report/domain/usecases/stream_report_usecase.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository reportRepository; 

  ReportBloc({required this.reportRepository}) : super(ReportInitial()) {
    on<SubmitEmergencyReport>(_onSubmitEmergencyReport);
    on<UpdateEmergencyReport>(_onUpdateEmergencyReport);
    on<ResetReportEvent>((event, emit) {
      emit(ReportInitial()); // Đưa state về trạng thái ban đầu
    });
  }

  Future<void> _onSubmitEmergencyReport(
    SubmitEmergencyReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      await reportRepository.submitReport(
        imageFile: event.imageFile,
        lat: event.lat,
        lng: event.lng,
        animalType: event.animalType,
        conditions: event.conditions,
        note: event.note,
      );
      emit(ReportSuccess());
    } catch (e) {
      emit(ReportFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
  Future<void> _onUpdateEmergencyReport(
    UpdateEmergencyReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      await reportRepository.updateReport(
        reportId: event.reportId,
        newImageFile: event.newImageFile,
        animalType: event.animalType,
        conditions: event.conditions,
        note: event.note,
      );
      emit(ReportSuccess());
    } catch (e) {
      emit(ReportFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
class MyReportBloc extends Bloc<ReportEvent, ReportState> {
  final StreamMyReportsUseCase streamMyReportsUseCase;
  final DeleteReportUseCase deleteReportUseCase;
  MyReportBloc({required this.streamMyReportsUseCase, required this.deleteReportUseCase}) : super(MyReportInitial()) {
    on<StartListeningMyReports>((event, emit) async {
      emit(MyReportLoading());
      await emit.forEach<List<AnimalReportModel>>(
        streamMyReportsUseCase.call(),
        onData: (reports) => MyReportLoaded(reports),
        onError: (error, stackTrace) => MyReportError("Lỗi tải lịch sử báo cáo"),
      );
    });
    on<DeleteReportEvent>((event, emit) async {
      try {
        await deleteReportUseCase.call(event.reportId);
        emit(MyReportError("Báo cáo đã được xóa thành công" ));
      } catch (e) {
        emit(MyReportError("Lỗi xóa báo cáo: ${e.toString()}"));
      }
      
    });
  }
}