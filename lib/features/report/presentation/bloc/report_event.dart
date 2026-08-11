import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitEmergencyReport extends ReportEvent {
  final File imageFile;
  final double lat;
  final double lng;
  final String animalType;
  final List<String> conditions;
  final String note;

  SubmitEmergencyReport({
    required this.imageFile,
    required this.lat,
    required this.lng,
    required this.animalType,
    required this.conditions,
    required this.note,
  });
}