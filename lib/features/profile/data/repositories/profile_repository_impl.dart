import 'package:paw_sos/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:paw_sos/features/profile/data/models/ProfileMode.dart';
import 'package:paw_sos/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileModel> getProfileData() async {
    return await remoteDataSource.getProfileData();
  }
}