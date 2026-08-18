
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/notification/domain/usecases/mark_noti_usecase.dart';
import 'package:paw_sos/features/notification/domain/usecases/stream_usecase.dart';
import 'package:paw_sos/features/notification/presentation/bloc/noti_event.dart';
import 'package:paw_sos/features/notification/presentation/bloc/noti_state.dart';
import 'package:paw_sos/features/notification/data/models/NotificationModel.dart';
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final StreamNotificationsUseCase streamNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationBloc({
    required this.streamNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationInitial()) {
    
    // Tự động hứng dữ liệu stream
    on<StartListeningNotifications>((event, emit) async {
      emit(NotificationLoading());
      
      // emit.forEach cập nhật State liên tục mỗi khi Stream có data mới
      await emit.forEach<List<NotificationModel>>(
        streamNotificationsUseCase.call(),
        onData: (notifications) => NotificationLoaded(notifications),
        onError: (error, stackTrace) => NotificationError("Lỗi tải thông báo"),
      );
    });

    on<MarkAsReadEvent>((event, emit) async {
      try {
        await markNotificationReadUseCase.call(event.notificationId);

        // Database cập nhật là Stream tự động nhả data mới về block StartListeningNotifications
      } catch (_) {}
    });
  }
}