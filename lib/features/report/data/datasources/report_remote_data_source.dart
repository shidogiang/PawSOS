import 'dart:io';
import 'dart:math';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReportRemoteDataSource {
  Future<void> submitReport({
    required File imageFile,
    required double lat,
    required double lng,
    required String animalType,
    required List<String> conditions,
    required String note,
  });

  Stream<List<AnimalReportModel>> streamMyReports();
  Future<void> deleteReport(String reportId);
  Future<void> updateReport({
    required String reportId,
    File? newImageFile,
    required String animalType,
    required List<String> conditions,
    required String note,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> submitReport({
    required File imageFile, required double lat, required double lng,
    required String animalType, required List<String> conditions, required String note,
  }) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception("Chưa đăng nhập");
    
    // 1. Upload ảnh báo cáo lên Storage
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.$fileExt';
    await supabaseClient.storage.from('report_images').upload(fileName, imageFile);
    final imageUrl = supabaseClient.storage.from('report_images').getPublicUrl(fileName);

    // 2. THUẬT TOÁN TẠO NHIỄU TỌA ĐỘ (BẢO MẬT VỊ TRÍ)
    final random = Random();
    // Tạo độ lệch ngẫu nhiên từ -0.005 đến +0.005 (Khoảng 300m - 500m)
    final latOffset = (random.nextDouble() * 0.01) - 0.005;
    final lngOffset = (random.nextDouble() * 0.01) - 0.005;
    
    final noiseLat = lat + latOffset;
    final noiseLng = lng + lngOffset;

    // 3. Đẩy thông tin nhiễu lên bảng Công Khai (animal_reports)
    final response = await supabaseClient.from('animal_reports').insert({
      'reporter_id': userId,
      'animal_type': animalType,
      'conditions': conditions,
      'description': note,
      'image_url': imageUrl,
      'noise_lat': noiseLat, // Trưng tọa độ ẢO ra ngoài Radar
      'noise_lng': noiseLng, // Trưng tọa độ ẢO ra ngoài Radar
      'status': 'OPEN'
    }).select('id').single(); // Ép trả về dòng vừa tạo để lấy ID!

    final reportId = response['id'];

    // 4. KHOÁ TỌA ĐỘ THẬT VÀO KÉT SẮT BẢO MẬT (Chỉ Hiệp sĩ mới mở được)
    await supabaseClient.from('secure_report_locations').insert({
      'report_id': reportId,
      'exact_lat': lat,
      'exact_lng': lng
    });
  }

  @override
  Stream<List<AnimalReportModel>> streamMyReports() {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return supabaseClient
        .from('animal_reports')
        .stream(primaryKey: ['id'])
        .eq('reporter_id', userId)
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => AnimalReportModel.fromJson(json)).toList());
  }
  @override
  Future<void> deleteReport(String reportId) async {
    await supabaseClient.from('animal_reports').delete().eq('id', reportId);
  }

  @override
  Future<void> updateReport({
    required String reportId, File? newImageFile,
    required String animalType, required List<String> conditions, required String note,
  }) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception("Chưa đăng nhập");

    final updateData = {
      'animal_type': animalType,
      'conditions': conditions,
      'description': note,
    };

    // Nếu người dùng chọn chụp ảnh mới, up ảnh lên và cập nhật link
    if (newImageFile != null) {
      final fileExt = newImageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.$fileExt';
      await supabaseClient.storage.from('report_images').upload(fileName, newImageFile);
      final newImageUrl = supabaseClient.storage.from('report_images').getPublicUrl(fileName);
      updateData['image_url'] = newImageUrl;
    }

    await supabaseClient.from('animal_reports').update(updateData).eq('id', reportId).eq('reporter_id', userId);
  }
}

