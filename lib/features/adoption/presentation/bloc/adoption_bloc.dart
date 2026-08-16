import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_event.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_state.dart';
import 'package:paw_sos/features/adoption/domain/usecases/submit_weekly_usecase.dart';
import 'package:paw_sos/features/adoption/domain/usecases/get_my_tracking_usecase.dart';
import 'package:paw_sos/features/adoption/domain/usecases/get_activity_stats_usecase.dart';
import 'package:paw_sos/features/adoption/data/models/AdoptionTrackingModel.dart';
class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final GetMyTrackingsUseCase getMyTrackingsUseCase;
  final SubmitWeeklyImageUseCase submitWeeklyImageUseCase;
  final GetActivityStatsUseCase getActivityStatsUseCase;
  AdoptionBloc({
    required this.getMyTrackingsUseCase,
    required this.submitWeeklyImageUseCase,
    required this.getActivityStatsUseCase,
  }) : super(AdoptionInitial()) {
    
    // XỬ LÝ LOAD DANH SÁCH
   on<LoadMyTrackings>((event, emit) async {
      emit(AdoptionLoading());
      try {
        // Chạy song song 2 API cực nhanh
        final results = await Future.wait([
          getMyTrackingsUseCase.call(),
          getActivityStatsUseCase.call(),
        ]);

        final trackings = results[0] as List<AdoptionTrackingModel>;
        final stats = results[1] as Map<String, int>;

        emit(AdoptionLoaded(
          trackings: trackings,
          rescuedCount: stats['rescued'] ?? 0,
          reportedCount: stats['reported'] ?? 0,
        ));
      } catch (e) {
        emit(AdoptionError("Lỗi tải tiến độ: ${e.toString()}"));
      }
    });

    // XỬ LÝ NỘP ẢNH TỪ UI TRUYỀN VÀO
    on<SubmitWeeklyPhotoEvent>((event, emit) async {
      emit(AdoptionLoading());
      try {
        await submitWeeklyImageUseCase.call(event.trackingId, event.weekNumber, event.imageFile);
        emit(AdoptionPhotoSubmitted("Tuyệt vời! Đã nộp ảnh Tuần ${event.weekNumber} thành công."));
        
        // Nộp xong thì Load lại danh sách cho UI tự động cập nhật Thanh Tiến Độ
        add(LoadMyTrackings());
      } catch (e) {
        emit(AdoptionError(e.toString()));
      }
    });
  }
}