import 'package:paw_sos/features/notification/data/models/NotificationModel.dart';
import 'package:paw_sos/features/notification/domain/repositories/noti_repository.dart';
class StreamNotificationsUseCase {
  final NotificationRepository repository;
  StreamNotificationsUseCase(this.repository);
  
  Stream<List<NotificationModel>> call() {
    return repository.streamMyNotifications();
  }
}