import 'package:flutter_bloc/flutter_bloc.dart';
import 'rescue_event.dart';
import 'rescue_state.dart';

import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/rescue/domain/usecases/get_radar_reports_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/accept_mission_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/get_ongoing_mission_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/complete_mission_usecase.dart';

class RescueBloc extends Bloc<RescueEvent, RescueState> {
  // BLoC CHỈ GIAO TIẾP VỚI USECASE
  final GetRadarReportsUseCase getRadarReportsUseCase;
  final AcceptMissionUseCase acceptMissionUseCase;
  final CheckOngoingMissionUseCase checkOngoingMissionUseCase;
  final CompleteMissionUseCase completeMissionUseCase;
  RescueBloc({
    required this.getRadarReportsUseCase,
    required this.acceptMissionUseCase,
    required this.checkOngoingMissionUseCase,
    required this.completeMissionUseCase,
  }) : super(RescueInitial()) {
    
    // Xử lý kéo dữ liệu Radar
    on<LoadRadarReports>((event, emit) async {
      emit(RescueLoading());
      try {
        // Dùng Future.wait để call 2 API cùng lúc
        final results = await Future.wait([
          getRadarReportsUseCase.call(),
          checkOngoingMissionUseCase.call(),
        ]);
        
        final reports = results[0] as List<AnimalReportModel>;
        final ongoing = results[1] as AnimalReportModel?;

        emit(RadarLoaded(reports: reports, ongoingMission: ongoing));
      } catch (e) {
        emit(RescueError("Lỗi tải Radar: ${e.toString()}"));
      }
    });

    // Xử lý Nhận ca cứu hộ
    on<AcceptMission>((event, emit) async {
      emit(RescueLoading());
      try {
        // GỌI QUA USECASE BẰNG HÀM .call()
        final success = await acceptMissionUseCase.call(event.reportId);
        if (success) {
          emit(RescueMissionAccepted());
        } else {
          emit(RescueError("Ca cứu hộ này đã có người khác nhận hoặc không tồn tại."));
        }
      } catch (e) {
        emit(RescueError(e.toString()));
      }
    });

    // Xử lý Hoàn thành ca cứu hộ
    // LUỒNG HOÀN TẤT NHIỆM VỤ
    on<CompleteMission>((event, emit) async {
      emit(RescueLoading());
      try {
        final success = await completeMissionUseCase.call(
            event.reportId, event.imageFile, event.resultStatus, event.note);
        if (success) {
          emit(RescueMissionCompleted());
        } else {
          emit(RescueError("Không thể hoàn tất nhiệm vụ, vui lòng thử lại!"));
        }
      } catch (e) {
        emit(RescueError(e.toString()));
      }
    });
    
  }
}