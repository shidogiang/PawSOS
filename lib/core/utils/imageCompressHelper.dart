import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompressHelper {
  /// Hàm nén ảnh thần thánh:
  /// Chuyển ảnh 10MB -> 300KB mà vẫn giữ được độ nét bằng thuật toán Native
  static Future<File?> compressImage(File file) async {
    try {
      // 1. Lấy đường dẫn file gốc và tạo đường dẫn cho file nén
      final filePath = file.absolute.path;
      
      // Tạo thư mục tạm để chứa ảnh nén, tránh rác bộ nhớ máy user
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(tempDir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // 2. Kích hoạt thuật toán nén
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath, 
        targetPath,
        quality: 70, // Giữ 70% chất lượng là điểm cân bằng hoàn hảo (Sweet spot)
        minWidth: 1080, // Ảnh không bao giờ to quá chiều ngang Full HD
        minHeight: 1080, 
        format: CompressFormat.jpeg, // Ép về JPEG cho nhẹ, loại bỏ PNG nặng nề
      );

      if (result != null) {
        // Log để đại ca thấy sự kỳ diệu của thuật toán
        final originalSize = await file.length() / 1024;
        final compressedSize = await result.length() / 1024;
        print('📸 [COMPRESS] Trước: ${originalSize.toStringAsFixed(0)} KB | Sau: ${compressedSize.toStringAsFixed(0)} KB');
        
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('❌ [COMPRESS ERROR]: $e');
      return file; // Nếu nén lỗi (hãn hữu), trả về file gốc để app không bị sập
    }
  }
}