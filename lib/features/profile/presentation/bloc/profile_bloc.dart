import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:paw_sos/features/profile/presentation/bloc/profile_event.dart';
import 'package:paw_sos/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase; // Chỉ giao tiếp với UseCase

  ProfileBloc({required this.getProfileUseCase}) : super(ProfileLoading()) {
    
    on<LoadProfileData>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profileData = await getProfileUseCase.call();
        
        emit(ProfileLoaded(
          displayName: profileData.displayName,
          joinDate: profileData.joinDate,
          trustScore: profileData.trustScore,
          rescuedCount: profileData.rescuedCount,
          reportedCount: profileData.reportedCount,
          adoptedCount: profileData.adoptedCount,
        ));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}