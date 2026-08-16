import 'package:equatable/equatable.dart';
abstract class AdoptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMyTrackings extends AdoptionEvent {}

class SubmitWeeklyPhotoEvent extends AdoptionEvent {
  final String trackingId;
  final int weekNumber;
  final dynamic imageFile;

  SubmitWeeklyPhotoEvent({required this.trackingId, required this.weekNumber, required this.imageFile});
}