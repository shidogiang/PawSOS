import '../../data/models/MessageModel.dart';
import '../repositories/message_repository.dart';

class StreamMessagesUseCase {
  final ChatRepository repository;
  StreamMessagesUseCase(this.repository);
  Stream<List<ChatMessageModel>> call(String reportId) => repository.streamMessages(reportId);
}