import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  // Chỉ giao tiếp qua Interface, không quan tâm bên dưới dùng Supabase hay Firebase
  final ReportRepository reportRepository; 

  ReportBloc({required this.reportRepository}) : super(ReportInitial()) {
    // Đăng ký lắng nghe event SubmitEmergencyReport
    on<SubmitEmergencyReport>(_onSubmitEmergencyReport);
  }

  // Hàm xử lý logic khi nhận được Event
  Future<void> _onSubmitEmergencyReport(
    SubmitEmergencyReport event,
    Emitter<ReportState> emit,
  ) async {
    // Báo cho UI biết là đang xử lý -> Hiện Overlay Loading
    emit(ReportLoading());
    
    try {
      // Gọi xuống tầng Data (Repository) để đẩy ảnh và data
      await reportRepository.submitReport(
        imageFile: event.imageFile,
        lat: event.lat,
        lng: event.lng,
        animalType: event.animalType,
        conditions: event.conditions,
        note: event.note,
      );
      
      // Nếu không có lỗi xảy ra thì báo Success -> UI tự đá về màn hình chính
      emit(ReportSuccess());
    } catch (e) {
      // Bắt lỗi rớt mạng, lỗi DB... và gửi về UI
      emit(ReportFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}