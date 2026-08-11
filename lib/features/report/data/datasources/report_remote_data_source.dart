import 'dart:io';
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
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> submitReport({
    required File imageFile,
    required double lat,
    required double lng,
    required String animalType,
    required List<String> conditions,
    required String note,
  }) async {
    // UPLOAD ẢNH LÊN STORAGE 
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    
    await supabaseClient.storage.from('report_images').upload(fileName, imageFile);
    final imageUrl = supabaseClient.storage.from('report_images').getPublicUrl(fileName);

    //GỌI HÀM RPC ĐỂ POSTGIS LO VIỆC TÍNH TOÁN TỌA ĐỘ VÀ CHIA 2 BẢNG
    await supabaseClient.rpc('create_emergency_report', params: {
      'p_animal_type': animalType,
      'p_conditions': conditions,
      'p_description': note,
      'p_image_url': imageUrl,
      'p_lat': lat,
      'p_lng': lng,
    });
  }
}