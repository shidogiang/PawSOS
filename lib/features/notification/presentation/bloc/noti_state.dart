import 'package:equatable/equatable.dart';
import 'package:paw_sos/features/notification/data/models/NotificationModel.dart';
abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationLoaded(this.notifications) : unreadCount = notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications, unreadCount];
}
class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}