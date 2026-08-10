import 'package:flutter/material.dart';
import 'dart:async';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  bool _isFrontDone = false;
  bool _isBackDone = false;
  bool _isSelfieDone = false;

  bool _isScanningSelfie = false;
  bool _isSubmitting = false;

  final String _mockCardImg = 'https://images.unsplash.com/photo-1621981386829-9b458a2cddde?q=80&w=300&auto=format&fit=crop';
  final String _mockSelfieImg = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';

  void _captureFront() {
    setState(() => _isFrontDone = true);
  }

  void _captureBack() {
    setState(() => _isBackDone = true);
  }

  void _captureSelfie() async {
    if (_isSelfieDone || _isScanningSelfie) return;

    setState(() => _isScanningSelfie = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isScanningSelfie = false;
        _isSelfieDone = true;
      });
    }
  }

  void _submitKyc() async {
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Hồ sơ KYC đã được gửi chờ duyệt!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        )
      );
      Navigator.pop(context);
    }
  }

  bool get _isAllDone => _isFrontDone && _isBackDone && _isSelfieDone;

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
        title: const Text('Xác thực Định danh', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nội dung cuộn
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Bảo mật
                  Container(
                    color: Colors.blue.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bảo vệ an toàn cộng đồng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                              const SizedBox(height: 4),
                              Text('Xác minh KYC giúp Paws SOS loại bỏ tài khoản ảo, ngăn chặn hành vi trộm cắp và bảo vệ định vị của động vật.', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //  SỐ ĐIỆN THOẠI
                        const Text('BƯỚC 1: LIÊN LẠC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: Icon(Icons.phone, color: Colors.green.shade500, size: 20)),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Số điện thoại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Text('+84 987 *** 509', style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace')),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [Icon(Icons.check, color: Colors.green.shade600, size: 12), const SizedBox(width: 4), Text('Đã xác thực', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold))]),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        //  CCCD
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('BƯỚC 2: CĂN CƯỚC / HỘ CHIẾU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                            Text('* Chỉ dùng camera trực tiếp', style: TextStyle(fontSize: 10, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildIdCardBox(title: 'Mặt trước', isDone: _isFrontDone, onTap: _captureFront)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildIdCardBox(title: 'Mặt sau', isDone: _isBackDone, onTap: _captureBack, isGrayscale: true)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        //  SELFIE AI
                        const Text('BƯỚC 3: AI NHẬN DIỆN CHÂN DUNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _captureSelfie,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: _isSelfieDone ? Colors.green.shade50 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isSelfieDone ? Colors.green.shade400 : Colors.grey.shade200)),
                            child: Row(
                              children: [
                                // Vòng tròn Avatar
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50, shape: BoxShape.circle,
                                    border: Border.all(color: _isSelfieDone ? Colors.green.shade400 : Colors.blue.shade300, width: 2, style: BorderStyle.solid),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: _isSelfieDone
                                        ? Image.network(_mockSelfieImg, fit: BoxFit.cover)
                                        : _isScanningSelfie
                                            ? const Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(strokeWidth: 2))
                                            : Icon(Icons.face, color: Colors.blue.shade400, size: 36),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Text hướng dẫn
                                Expanded(
                                  child: _isSelfieDone 
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 16), const SizedBox(width: 6), Text('AI xác nhận người thật', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
                                          const SizedBox(height: 4),
                                          const Text('Khuôn mặt khớp 98% với CCCD.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Chụp ảnh chân dung', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: const TextSpan(
                                              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                                              children: [
                                                TextSpan(text: 'Hệ thống AI ML Kit sẽ yêu cầu bạn '),
                                                TextSpan(text: 'chớp mắt', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                                TextSpan(text: ' hoặc '),
                                                TextSpan(text: 'mỉm cười', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                                TextSpan(text: ' để đảm bảo bạn là người thật.'),
                                              ]
                                            ),
                                          )
                                        ],
                                      ),
                                )
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                          child: const Text('Dữ liệu được mã hóa chuẩn quốc tế và xóa khỏi máy chủ sau khi hệ thống phê duyệt.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // STICKY BUTTON BOTTOM
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: _isAllDone ? _submitKyc : null,
                  icon: const Icon(Icons.send),
                  label: const Text('GỬI HỒ SƠ XÉT DUYỆT', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300, disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),

          // OVERLAY LOADING (Khi Submit)
          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.blue),
                    const SizedBox(height: 24),
                    const Text('Hệ thống đang mã hóa...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text('Đang đồng bộ lên Supabase Vault', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  // Helper cho ô chụp CCCD
  Widget _buildIdCardBox({required String title, required bool isDone, required VoidCallback onTap, bool isGrayscale = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDone ? Colors.blue.shade500 : Colors.grey.shade300, width: isDone ? 2 : 1),
          ),
          child: isDone
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColorFiltered(
                      colorFilter: isGrayscale ? const ColorFilter.matrix([0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0]) : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: Image.network(_mockCardImg, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 12))),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: Icon(Icons.badge, color: Colors.blue.shade400)),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
        ),
      ),
    );
  }
}