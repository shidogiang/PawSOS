import 'package:equatable/equatable.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';

abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}
class ReportInitial extends ReportState {}
class ReportLoading extends ReportState {}
class ReportSuccess extends ReportState {}
class ReportFailure extends ReportState {
  final String message;
  ReportFailure(this.message);
}
class MyReportInitial extends ReportState {}
class MyReportLoading extends ReportState {}
class MyReportLoaded extends ReportState {
  final List<AnimalReportModel> reports;
  MyReportLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}
class MyReportError extends ReportState {
  final String message;
  MyReportError(this.message);
  @override
  List<Object?> get props => [message];
}