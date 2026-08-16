import 'package:equatable/equatable.dart';
import 'package:paw_sos/features/adoption/data/models/AdoptionTrackingModel.dart';

abstract class AdoptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdoptionInitial extends AdoptionState {}
class AdoptionLoading extends AdoptionState {}

class AdoptionLoaded extends AdoptionState {
  final List<AdoptionTrackingModel> trackings;
  final int rescuedCount;   // THÊM BIẾN NÀY
  final int reportedCount; 
  AdoptionLoaded({
     required this.trackings,  required this.rescuedCount,  required this.reportedCount});
  @override
  List<Object?> get props => [trackings, rescuedCount, reportedCount];
}

class AdoptionPhotoSubmitted extends AdoptionState {
  final String message;
  AdoptionPhotoSubmitted(this.message);
  @override
  List<Object?> get props => [message];
}

class AdoptionError extends AdoptionState {
  final String message;
  AdoptionError(this.message);
  @override
  List<Object?> get props => [message];
}