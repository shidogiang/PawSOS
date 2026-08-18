import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/UserModel.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(String fullName, String phone, String password);
  Future<UserModel> login(String phone, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);
//  Email giả từ Số điện thoại
  String _generateFakeEmail(String phone) {
    final cleanPhone = phone.replaceAll('+', ''); // Xóa dấu +
    return '$cleanPhone@pawssos.com';
  }
  @override
  Future<UserModel> register(String fullName, String phone, String password) async {
    // Dữ liệu 'full_name' và 'phone' được nhét vào thẻ 'data' (metadata).
    // Dữ liệu này sẽ được Trigger handle_new_user() dưới SQL DB móc ra và insert vào bảng public.users.
    final fakeEmail = _generateFakeEmail(phone);
    final AuthResponse res = await supabaseClient.auth.signUp(
      email: fakeEmail,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );

    if (res.user == null) {
      throw Exception("Lỗi: Không thể tạo tài khoản xác thực.");
    }

    final response = await supabaseClient
        .from('users')
        .select()
        .eq('id', res.user!.id)
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> login(String phone, String password) async {
    // Gọi API signIn của Supabase để lấy Access Token
    final fakeEmail = _generateFakeEmail(phone);
    final AuthResponse res = await supabaseClient.auth.signInWithPassword(
      email: fakeEmail,
      password: password,
    );

    if (res.user == null) {
      throw Exception("Sai số điện thoại hoặc mật khẩu!");
    }

    final response = await supabaseClient
        .from('users')
        .select()
        .eq('id', res.user!.id)
        .single();

    return UserModel.fromJson(response);
  }
  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}
