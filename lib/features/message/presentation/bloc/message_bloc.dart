import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/stream_message_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../data/models/MessageModel.dart';
import 'message_event.dart';
import 'message_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final StreamMessagesUseCase streamMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatBloc({
    required this.streamMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatInitial()) {
    
    // xem flow mess
    on<StartListeningChat>((event, emit) async {
      emit(ChatLoading());
      await emit.forEach<List<ChatMessageModel>>(
        streamMessagesUseCase.call(event.reportId),
        onData: (messages) => ChatLoaded(messages),
        onError: (error, stackTrace) => ChatError("Lỗi tải tin nhắn"),
      );
    });

    // Gửi mess
    on<SendMessageEvent>((event, emit) async {
      try {
        await sendMessageUseCase.call(event.reportId, event.message);
      } catch (e) {
        print('🔥 [DEBUG] Lỗi gửi tin nhắn: $e');      }
    });
  }
}