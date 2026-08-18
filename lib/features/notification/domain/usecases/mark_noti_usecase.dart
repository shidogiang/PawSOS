import 'package:paw_sos/features/notification/domain/repositories/noti_repository.dart';
class MarkNotificationReadUseCase {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);
  
  Future<void> call(String id) async {
    return await repository.markAsRead(id);
  }
}