import 'package:paw_sos/features/notification/data/datasources/noti_remote_datasource.dart';
import 'package:paw_sos/features/notification/data/models/NotificationModel.dart';
import 'package:paw_sos/features/notification/domain/repositories/noti_repository.dart';
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<NotificationModel>> streamMyNotifications() => remoteDataSource.streamMyNotifications();

  @override
  Future<void> markAsRead(String notificationId) async => await remoteDataSource.markAsRead(notificationId);
}