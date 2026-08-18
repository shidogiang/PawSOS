import 'package:paw_sos/features/profile/data/models/ProfileMode.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfileData();
}