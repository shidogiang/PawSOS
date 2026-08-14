import 'package:equatable/equatable.dart';

abstract class RescueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRadarReports extends RescueEvent {}

class AcceptMission extends RescueEvent {
  final String reportId;
  AcceptMission(this.reportId);
}
class CompleteMission extends RescueEvent {
  final String reportId;
  final dynamic imageFile; // Thêm trường cho ảnh minh chứng
  final String resultStatus; // Trạng thái kết quả cứu hộ
  final String note; // Ghi chú thêm

  CompleteMission(
     this.reportId,
     this.imageFile,
     this.resultStatus,
     this.note,
  );

  @override
  List<Object?> get props => [reportId, imageFile, resultStatus, note];
}