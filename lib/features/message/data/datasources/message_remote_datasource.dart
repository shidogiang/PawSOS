import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/MessageModel.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> streamMessages(String reportId);
  Future<void> sendMessage(String reportId, String message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl(this.supabaseClient);

  @override
  Stream<List<ChatMessageModel>> streamMessages(String reportId) {
    //  Lấy tin nhắn Real-time, sắp xếp mới nhất xếp trước 
    return supabaseClient
        .from('rescue_chats')
        .stream(primaryKey: ['id'])
        .eq('report_id', reportId)
        .order('created_at', ascending: false) 
        .map((list) => list.map((json) => ChatMessageModel.fromJson(json)).toList());
  }

  @override
  Future<void> sendMessage(String reportId, String message) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception("Chưa đăng nhập!");

    await supabaseClient.from('rescue_chats').insert({
      'report_id': reportId,
      'sender_id': userId,
      'message': message,
    });
  }
}