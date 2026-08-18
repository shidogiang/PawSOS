
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String displayName;
  final String joinDate;
  final int trustScore;
  final int rescuedCount;
  final int reportedCount;
  final int adoptedCount;

  ProfileLoaded({
    required this.displayName, required this.joinDate, required this.trustScore,
    required this.rescuedCount, required this.reportedCount, required this.adoptedCount,
  });

  @override
  List<Object?> get props => [displayName, joinDate, trustScore, rescuedCount, reportedCount, adoptedCount];
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}