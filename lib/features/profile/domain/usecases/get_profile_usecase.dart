import 'package:paw_sos/features/profile/data/models/ProfileMode.dart';
import 'package:paw_sos/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<ProfileModel> call() async {
    return await repository.getProfileData();
  }
}