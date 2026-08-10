import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/UserModel.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(String fullName, String phone, String password);
  Future<UserModel> login(String phone, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> register(String fullName, String phone, String password) async {
    final AuthResponse res = await supabaseClient.auth.signUp(
      phone: phone,
      password: password,
    );

    if (res.user == null) {
      throw Exception("Lỗi: Không thể tạo tài khoản Supabase Auth");
    }

    final userData = {
      'id': res.user!.id,
      'full_name': fullName,
      'phone_number': phone,
      'password_hash': 'SUPABASE_HANDLED', 
      'is_kyc_verified': false,
    };

    final response = await supabaseClient
        .from('users')
        .insert(userData)
        .select() 
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> login(String phone, String password) async {
    final AuthResponse res = await supabaseClient.auth.signInWithPassword(
      phone: phone,
      password: password,
    );

    if (res.user == null) throw Exception("Sai số điện thoại hoặc mật khẩu!");

    final response = await supabaseClient
        .from('users')
        .select()
        .eq('id', res.user!.id)
        .single();

    return UserModel.fromJson(response);
  }
}