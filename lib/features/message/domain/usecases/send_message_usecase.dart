import '../repositories/message_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);
  Future<void> call(String reportId, String message) async => await repository.sendMessage(reportId, message);
}