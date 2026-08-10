import 'package:flutter/material.dart';
import 'dart:async'; 

class ReportEmergencyScreen extends StatefulWidget {
  const ReportEmergencyScreen({super.key});

  @override
  State<ReportEmergencyScreen> createState() => _ReportEmergencyScreenState();
}

class _ReportEmergencyScreenState extends State<ReportEmergencyScreen> with SingleTickerProviderStateMixin {
  bool _hasPhoto = false;
  String _mockImageUrl = '';
  
  // GPS State
  bool _isFetchingGps = true;
  String _gpsLat = '';
  String _gpsLng = '';
  
  // Selection State
  String _selectedAnimalType = 'Mèo'; 
  final List<String> _selectedConditions = []; 
  
  // Loading & Success State
  bool _isSubmitting = false;
  bool _isSuccess = false;

  // Animation cho nút Camera 
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Cài đặt Animation nhấp nháy 2 giây lặp lại liên tục
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Mô phỏng quá trình tự động lấy GPS mất 1.5 giây
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isFetchingGps = false;
          _gpsLat = '10.762622';
          _gpsLng = '106.660172';
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openCamera() {
    // TODO: Tích hợp thư viện image_picker ở đây
    setState(() {
      _hasPhoto = true;
      _mockImageUrl = 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80';
    });
  }

  void _retakePhoto() {
    setState(() {
      _hasPhoto = false;
      _mockImageUrl = '';
    });
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  void _submitReport() async {
    // Ẩn bàn phím nếu đang bật
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSuccess = true; 
      });
      
      // Đợi thêm 2 giây để user đọc thông báo rồi tự back về Home
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Báo cáo khẩn cấp',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          //  SCROLLABLE FORM
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), 
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCameraSection(),
                  _buildGPSSection(),
                  Divider(color: Colors.grey.shade300, thickness: 4, height: 32),
                  _buildTypeSelection(),
                  _buildConditionSelection(),
                  _buildNoteSection(),
                ],
              ),
            ),
          ),

          //  STICKY BOTTOM BUTTON 
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                // Nút chỉ bấm được khi _hasPhoto == true
                onPressed: _hasPhoto ? _submitReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _hasPhoto ? 2 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    const SizedBox(width: 8),
                    const Text('Phát Tín Hiệu SOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          //  OVERLAY LOADING & SUCCESS
          if (_isSubmitting)
            Container(
              color: Colors.white.withOpacity(0.9),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isSuccess) ...[
                      const CircularProgressIndicator(color: Color(0xFFF43F5E)),
                      const SizedBox(height: 16),
                      const Text('Đang mã hóa tọa độ...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Vui lòng không đóng ứng dụng', style: TextStyle(color: Colors.grey)),
                    ] else ...[
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.green, size: 36),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tín hiệu đã phát!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Hệ thống đã tạo vùng nhiễu an toàn trên bản đồ.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ]
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Component con

  Widget _buildCameraSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Ảnh hiện trường ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))],
                ),
              ),
              const Text('Chỉ chụp trực tiếp', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _hasPhoto ? null : _openCamera,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2), 
                  image: _hasPhoto ? DecorationImage(image: NetworkImage(_mockImageUrl), fit: BoxFit.cover) : null,
                ),
                child: _hasPhoto 
                  ? Stack(
                      children: [
                        Positioned(
                          bottom: 12, right: 12,
                          child: InkWell(
                            onTap: _retakePhoto,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text('Chụp lại', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hiệu ứng Pulse Animation cho nút Camera
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(1 - _pulseController.value), // Càng to càng mờ
                                    spreadRadius: _pulseController.value * 20, // Lan rộng ra
                                  )
                                ],
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.red.shade400, size: 30),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Chạm để mở Camera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Hệ thống sẽ nén ảnh tự động', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
              child: _isFetchingGps 
                  ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.location_on, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ĐỊNH VỊ GPS TỰ ĐỘNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 2),
                  Text(
                    _isFetchingGps ? 'Đang thu thập tọa độ...' : 'Lat: $_gpsLat, Lng: $_gpsLng',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isFetchingGps ? 'Độ chính xác: Đang tính...' : 'Độ chính xác: Tuyệt đối (4m)',
                    style: TextStyle(fontSize: 11, color: _isFetchingGps ? Colors.grey : Colors.green.shade700),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Phân loại ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTypeItem('Chó', Icons.pets),
              const SizedBox(width: 12),
              _buildTypeItem('Mèo', Icons.pets), 
              const SizedBox(width: 12),
              _buildTypeItem('Khác', Icons.help_outline),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTypeItem(String type, IconData icon) {
    bool isSelected = _selectedAnimalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedAnimalType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red.shade50 : Colors.white,
            border: Border.all(color: isSelected ? const Color(0xFFF43F5E) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFFF43F5E) : Colors.grey),
              const SizedBox(height: 4),
              Text(
                type, 
                style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFFF43F5E) : Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionSelection() {
    final conditions = ['🩸 Bị thương', '⛓️ Mắc kẹt', '🥺 Suy kiệt / Đói', '🌧️ Dầm mưa/Lạnh', '❓ Không rõ'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tình trạng hiện tại (Chọn nhiều)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: conditions.map((cond) {
              bool isSelected = _selectedConditions.contains(cond);
              return GestureDetector(
                onTap: () => _toggleCondition(cond),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade800 : Colors.white,
                    border: Border.all(color: isSelected ? Colors.grey.shade800 : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cond,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả thêm (Tùy chọn)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Bé mèo con nằm dưới gầm xe màu đen...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF43F5E))),
            ),
          )
        ],
      ),
    );
  }
}