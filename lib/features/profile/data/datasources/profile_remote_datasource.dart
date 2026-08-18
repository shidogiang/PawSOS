import 'package:paw_sos/features/profile/data/models/ProfileMode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfileData();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProfileModel> getProfileData() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    //  Lấy thông tin cơ bản
    final metadata = user.userMetadata ?? {};
    final displayName = metadata['full_name'] ?? user.email?.split('@')[0] ?? 'Hiệp Sĩ Ẩn Danh';
    
    // Format ngày tháng
    final DateTime createdAt = DateTime.parse(user.createdAt);
    final String joinDate = 'Thg ${createdAt.month}, ${createdAt.year}';

     // Ép kiểu rõ ràng về Future<dynamic> để Dart không bị lú lẫn khi trộn Map và List
    final Future<dynamic> q1 = supabaseClient.from('users').select('trust_score').eq('id', user.id).maybeSingle();
    final Future<dynamic> q2 = supabaseClient.from('animal_reports').select('id').eq('rescuer_id', user.id).eq('status', 'RESOLVED');
    final Future<dynamic> q3 = supabaseClient.from('animal_reports').select('id').eq('reporter_id', user.id);
    final Future<dynamic> q4 = supabaseClient.from('adoption_tracking').select('id').eq('adopter_id', user.id);

    final results = await Future.wait([q1, q2, q3, q4]);

    final userRow = results[0] as Map<String, dynamic>?;
    final trustScore = userRow?['trust_score'] ?? 100; // Mặc định 100 điểm
    final rescuedCount = (results[1] as List).length;
    final reportedCount = (results[2] as List).length;
    final adoptedCount = (results[3] as List).length;

    return ProfileModel(
      displayName: displayName,
      joinDate: joinDate,
      trustScore: trustScore,
      rescuedCount: rescuedCount,
      reportedCount: reportedCount,
      adoptedCount: adoptedCount,
    );
  }
}