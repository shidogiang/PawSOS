import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity> login(String phone, String password);
  Future<UserEntity> register({
    required String fullName,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}