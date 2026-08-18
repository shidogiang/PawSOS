import 'package:paw_sos/features/notification/data/models/NotificationModel.dart';
abstract class NotificationRepository {
  Stream<List<NotificationModel>> streamMyNotifications();
  Future<void> markAsRead(String notificationId);
}