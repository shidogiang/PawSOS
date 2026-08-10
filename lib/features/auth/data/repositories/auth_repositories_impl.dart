import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> register({required String fullName, required String phone, required String password}) async {
    // có thể thêm logic kiểm tra mạng 
    return await remoteDataSource.register(fullName, phone, password);
  }

  @override
  Future<UserEntity> login(String phone, String password) async {
    return await remoteDataSource.login(phone, password);
  }

  @override
  Future<void> logout() async {
    // Sẽ implement gọi supabase.auth.signOut() sau
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Sẽ implement kiểm tra session sau
    return null; 
  }
}