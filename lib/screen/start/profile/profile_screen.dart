import 'package:flutter/material.dart';
import 'package:paw_sos/features/auth/presentation/pages/login_screen.dart'; 
import 'package:paw_sos/screen/start/profile/kyc_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
  
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // Xóa toàn bộ stack cũ
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // Header Đỏ 
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.red.shade600,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Nền gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.red.shade500, Colors.red.shade600],
                      ),
                    ),
                  ),
                  // Họa tiết chân chó 
                  Positioned(
                    top: 40, right: 20,
                    child: Transform.rotate(
                      angle: -0.2, // -12 độ
                      child: Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  Positioned(
                    top: 100, left: 40,
                    child: Transform.rotate(
                      angle: 0.2, // 12 độ
                      child: Icon(Icons.pets, size: 50, color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  // Title và Nút Cài đặt
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tài khoản', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: IconButton(icon: const Icon(Icons.settings, color: Colors.white, size: 20), onPressed: () {}),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Nội dung chính nằm đè lên Header (Sử dụng SliverToBoxAdapter + Transform)
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40), // Kéo nội dung xích lên trên 40px để đè lên nền đỏ
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    //  Main Profile Card 
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar VIP Ring
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [Colors.red, Colors.amber, Colors.red], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: const CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Trần Văn A', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.verified, color: Colors.blue, size: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Thành viên từ Thg 8, 2026', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Trust Score Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('ĐIỂM TÍN NHIỆM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text('125', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green)),
                                            const SizedBox(width: 4),
                                            Text('/ 200', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                                          ],
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Icon(Icons.shield, size: 12, color: Colors.green.shade700),
                                          const SizedBox(width: 4),
                                          Text('Bậc Hiệp Sĩ', style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 125 / 200,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.green.shade500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Quyền lợi: Mở khóa GPS tức thì không cần chờ duyệt.', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    //  Stats Grid 
                    Row(
                      children: [
                        _buildStatBox(icon: Icons.volunteer_activism, iconColor: Colors.red, bgColor: Colors.red.shade50, value: '12', label: 'Đã Cứu'),
                        const SizedBox(width: 12),
                        _buildStatBox(icon: Icons.campaign, iconColor: Colors.blue, bgColor: Colors.blue.shade50, value: '5', label: 'Báo Cáo'),
                        const SizedBox(width: 12),
                        _buildStatBox(icon: Icons.home, iconColor: Colors.purple, bgColor: Colors.purple.shade50, value: '3', label: 'Nhận Nuôi'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    //  Menu Settings 
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
                      child: Column(
                        children: [
                          _buildMenuItem(icon: Icons.badge, iconColor: Colors.blue, bgColor: Colors.blue.shade50, 
                          title: 'Xác thực CCCD (KYC)', subtitle: 'Đã xác minh an toàn', subtitleColor: Colors.green.shade500,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const KycScreen()),
                            );
                          }
                          ),
                          _buildDivider(),
                          _buildMenuItem(icon: Icons.radar, iconColor: Colors.red, bgColor: Colors.red.shade50, title: 'Cấu hình Radar SOS', subtitle: 'Bán kính hiện tại: 5 km'),
                          _buildDivider(),
                          _buildMenuItem(icon: Icons.local_hospital, iconColor: Colors.orange, bgColor: Colors.orange.shade50, title: 'Trạm thú y liên kết', subtitle: 'Danh sách & Hotline khẩn cấp'),
                          _buildDivider(),
                          _buildMenuItem(icon: Icons.history, iconColor: Colors.grey.shade600, bgColor: Colors.grey.shade100, title: 'Lịch sử Trừ/Cộng điểm', subtitle: 'Log hoạt động tín nhiệm'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          side: BorderSide(color: Colors.red.shade100),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Dựng 1 ô Thống kê nhỏ
  Widget _buildStatBox({required IconData icon, required Color iconColor, required Color bgColor, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, height: 1)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // Dựng Dòng Menu Cài đặt
  Widget _buildMenuItem({
    required IconData icon, 
    required Color iconColor, 
    required Color bgColor, 
    required String title, 
    required String subtitle, 
    Color? subtitleColor,
    VoidCallback? onTap
    }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subtitleColor ?? Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 68);
  }
}