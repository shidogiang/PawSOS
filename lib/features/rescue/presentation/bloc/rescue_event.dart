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