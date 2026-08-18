import 'package:flutter/material.dart';
import 'package:paw_sos/features/auth/presentation/pages/login_screen.dart';
import 'package:paw_sos/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:paw_sos/features/profile/presentation/bloc/profile_event.dart';
import 'package:paw_sos/features/profile/presentation/bloc/profile_state.dart'; 
import 'package:paw_sos/screen/start/profile/kyc_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileData());
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Đang đồng bộ hồ sơ...', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            } 
            
            if (state is ProfileError) {
              return Center(child: Text('Lỗi tải hồ sơ: ${state.message}', style: const TextStyle(color: Colors.red)));
            }
            
            if (state is ProfileLoaded) {
              return _buildProfileContent(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileLoaded data) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none, // ava lồi ra ngoài khối
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.red.shade500, Colors.red.shade600],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Stack(
                  children: [
                    Positioned(top: 40, right: -20, child: Transform.rotate(angle: -0.2, child: Icon(Icons.pets, size: 100, color: Colors.white.withOpacity(0.1)))),
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

              Positioned(
                bottom: -50, 
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, 
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 3), 
                    ),
                    child: const CircleAvatar(
                      radius: 46, 
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop')
                    ),
                  ),
                ),
              )
            ],
          ),
        ),

        // thông tin hồ sơ
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Spacer để chừa chỗ cho cái cục Avatar lồi xuống
                const SizedBox(height: 60), 

                // Tên & Ngày tham gia 
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(data.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Thành viên từ ${data.joinDate}', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Điểm Tín Nhiệm
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))]),
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
                                  Text(data.trustScore.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.green)),
                                  const SizedBox(width: 4),
                                  Text('/ 200', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                                ],
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
                            child: Row(
                              children: [
                                Icon(Icons.shield, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 6),
                                Text('Bậc Hiệp Sĩ', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (data.trustScore / 200).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.green.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Expanded(child: Text('Quyền lợi: Mở khóa GPS tức thì không cần chờ duyệt.', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Khối Thống Kê
                Row(
                  children: [
                    _buildStatBox(icon: Icons.volunteer_activism, iconColor: Colors.red, bgColor: Colors.red.shade50, value: data.rescuedCount.toString(), label: 'Đã Cứu'),
                    const SizedBox(width: 12),
                    _buildStatBox(icon: Icons.campaign, iconColor: Colors.blue, bgColor: Colors.blue.shade50, value: data.reportedCount.toString(), label: 'Báo Cáo'),
                    const SizedBox(width: 12),
                    _buildStatBox(icon: Icons.home, iconColor: Colors.purple, bgColor: Colors.purple.shade50, value: data.adoptedCount.toString(), label: 'Nhận Nuôi'),
                  ],
                ),
                const SizedBox(height: 24),

                //  Chức Năng
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.badge, iconColor: Colors.blue, bgColor: Colors.blue.shade50, 
                        title: 'Xác thực CCCD (KYC)', subtitle: 'Đã xác minh an toàn', subtitleColor: Colors.green.shade500,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen()))
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

                //  Đăng Xuất
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
        )
      ],
    );
  }

  Widget _buildStatBox({required IconData icon, required Color iconColor, required Color bgColor, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

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
