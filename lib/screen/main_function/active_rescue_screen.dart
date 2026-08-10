import '/model/AnimalReportModel.dart';
import 'package:flutter/material.dart';
import 'package:paw_sos/screen/main_function/contact/chat_screen.dart';
import 'package:paw_sos/screen/main_function/contact/call_screen.dart';
class ActiveRescueScreen extends StatelessWidget {
  final AnimalReportModel mission;

  const ActiveRescueScreen({super.key, required this.mission});
void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Hủy cứu hộ?'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn hủy nhiệm vụ này không? Việc hủy ngang sẽ làm giảm Điểm Tín Nhiệm cứu hộ của bạn.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Đóng dialog
            child: const Text('QUAY LẠI', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 1 Gọi API báo cho Supabase là đã hủy ca này để người khác còn nhận
              // 2. Thoát màn hình cứu hộ, trở về Radar
              Navigator.pop(context); 
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ĐỒNG Ý HỦY', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          // Bản đồ giả lập (Trong thực tế sẽ là Google Map tracking)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Điểm ghim Tọa độ chính xác
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.5 - 60,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Định vị chính xác (4m)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.location_on, color: Colors.red, size: 50),
              ],
            ),
          ),

          // 3. Thanh trạng thái trên cùng 
          Positioned(
            top: 50, left: 16, right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red), 
                    onPressed: () {
                      _showCancelDialog(context);
                    }
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade400)),
                    child: const Row(
                      children: [
                        Icon(Icons.directions_run, color: Colors.green), SizedBox(width: 8),
                        Text('ĐANG TRONG NHIỆM VỤ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel Điều hướng dưới (Cố định, che luôn chỗ cũ của Bottom Nav)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thông tin bé
                    Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(mission.imageUrl, width: 50, height: 50, fit: BoxFit.cover)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mission.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Đã mở khóa tọa độ GPS thật', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade200,
                            radius: 18,
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Người báo cáo', style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w600)),
                                const Text('Nguyễn Văn A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                          // Nút Nhắn tin
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const ChatScreen(reporterName: 'Nguyễn Văn A'))
                            );
                            },
                            icon: const Icon(Icons.chat_bubble_rounded, color: Colors.blue, size: 20),
                            style: IconButton.styleFrom(backgroundColor: Colors.white, shadowColor: Colors.black12, elevation: 1),
                          ),
                          const SizedBox(width: 8),
                          // Nút Gọi điện
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CallScreen(reporterName: 'Nguyễn Văn A'))
                              );
                            },
                            icon: const Icon(Icons.phone_in_talk, color: Colors.green, size: 20),
                            style: IconButton.styleFrom(backgroundColor: Colors.white, shadowColor: Colors.black12, elevation: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    //  Nút chức năng chính
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {}, icon: const Icon(Icons.directions), label: const Text('Chỉ đường'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.blue)),
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Đã tới nơi'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                          )
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}