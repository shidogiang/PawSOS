import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_sos/features/notification/data/models/NotificationModel.dart';

abstract class NotificationRemoteDataSource {
  // Trả về một data Stream tức là có thay đổi là nó tự stream 
  Stream<List<NotificationModel>> streamMyNotifications();
  Future<void> markAsRead(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;
  NotificationRemoteDataSourceImpl(this.supabaseClient);

  @override
  Stream<List<NotificationModel>> streamMyNotifications() {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    // Mở WebSockets, lắng nghe mọi thay đổi của bảng notifications có user_id của mình
    return supabaseClient
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false) 
        .map((list) => list.map((json) => NotificationModel.fromJson(json)).toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await supabaseClient
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
}