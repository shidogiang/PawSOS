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
  final dynamic imageFile; 
  final String resultStatus; 
  final String note; 
  CompleteMission(
     this.reportId,
     this.imageFile,
     this.resultStatus,
     this.note,
  );

  @override
  List<Object?> get props => [reportId, imageFile, resultStatus, note];
}
class CancelMissionEvent extends RescueEvent {
  final String reportId;
  CancelMissionEvent(this.reportId);
  
  @override
  List<Object?> get props => [reportId];
}