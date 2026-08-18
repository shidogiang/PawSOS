import '../../data/models/MessageModel.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageModel>> streamMessages(String reportId);
  Future<void> sendMessage(String reportId, String message);
}