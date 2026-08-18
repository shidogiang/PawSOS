
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartListeningNotifications extends NotificationEvent {}
class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;
  MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}