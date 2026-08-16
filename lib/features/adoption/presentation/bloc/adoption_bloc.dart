import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_event.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_state.dart';
import 'package:paw_sos/features/adoption/domain/usecases/submit_weekly_usecase.dart';
import 'package:paw_sos/features/adoption/domain/usecases/get_my_tracking_usecase.dart';

class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final GetMyTrackingsUseCase getMyTrackingsUseCase;
  final SubmitWeeklyImageUseCase submitWeeklyImageUseCase;

  AdoptionBloc({
    required this.getMyTrackingsUseCase,
    required this.submitWeeklyImageUseCase,
  }) : super(AdoptionInitial()) {
    
    // XỬ LÝ LOAD DANH SÁCH
    on<LoadMyTrackings>((event, emit) async {
      emit(AdoptionLoading());
      try {
        final trackings = await getMyTrackingsUseCase.call();
        emit(AdoptionLoaded(trackings));
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