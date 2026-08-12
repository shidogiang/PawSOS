import 'package:equatable/equatable.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
abstract class RescueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RescueInitial extends RescueState {}
class RescueLoading extends RescueState {}

class RadarLoaded extends RescueState {
  final List<AnimalReportModel> reports;
  RadarLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}

class RescueMissionAccepted extends RescueState {}

class RescueError extends RescueState {
  final String message;
  RescueError(this.message);
  @override
  List<Object?> get props => [message];
}