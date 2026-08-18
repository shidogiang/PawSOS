import 'package:flutter_bloc/flutter_bloc.dart';
import 'rescue_event.dart';
import 'rescue_state.dart';

import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/rescue/domain/usecases/get_radar_reports_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/accept_mission_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/get_ongoing_mission_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/complete_mission_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/cancel_mission_usecase.dart';

class RescueBloc extends Bloc<RescueEvent, RescueState> {
  final GetRadarReportsUseCase getRadarReportsUseCase;
  final AcceptMissionUseCase acceptMissionUseCase;
  final CheckOngoingMissionUseCase checkOngoingMissionUseCase;
  final CompleteMissionUseCase completeMissionUseCase;
  final CancelMissionUseCase cancelMissionUseCase;

  RescueBloc({
    required this.getRadarReportsUseCase,
    required this.acceptMissionUseCase,
    required this.checkOngoingMissionUseCase,
    required this.completeMissionUseCase,
    required this.cancelMissionUseCase,
  }) : super(RescueInitial()) {
    on<LoadRadarReports>((event, emit) async {
      emit(RescueLoading());
      try {
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

    on<AcceptMission>((event, emit) async {
      emit(RescueLoading());
      try {
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

    on<CancelMissionEvent>((event, emit) async {
      emit(RescueLoading());
      try {
        final success = await cancelMissionUseCase.call(event.reportId);
        if (success) {
          emit(RescueMissionCanceled());
        } else {
          emit(RescueError("Không thể hủy ca lúc này, vui lòng thử lại!"));
        }
      } catch (e) {
        emit(RescueError(e.toString()));
      }
    });
  }
}