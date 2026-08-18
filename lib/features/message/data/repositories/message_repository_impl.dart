import '../../data/models/MessageModel.dart';
import '../datasources/message_remote_datasource.dart';
import '../../domain/repositories/message_repository.dart';


class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<ChatMessageModel>> streamMessages(String reportId) => remoteDataSource.streamMessages(reportId);

  @override
  Future<void> sendMessage(String reportId, String message) async => await remoteDataSource.sendMessage(reportId, message);
}