import 'package:flutter/material.dart';
import 'package:paw_sos/screen/card/home_function_card/report_card.dart';
import 'package:paw_sos/screen/card/home_function_card/hero_service_card.dart';
import 'package:paw_sos/features/report/presentation/pages/report_screen.dart';
import 'package:paw_sos/features/rescue/presentation/pages/rescue_map_screen.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart'; 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AnimalReportModel> recentReports = AnimalReportModel.getMockData();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFFF43F5E),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vị trí hiện tại',
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '123 Lê Lợi, Q.1, TP.HCM',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFFF43F5E), Colors.red.shade400],
                  ),
                ),
              ),
            ),
          ),

          // Nội dung trang chủ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào,👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Hero Services 
                  Row(
                    children: [
                      HeroServiceCard(
                        title: 'Báo cáo\nKhẩn cấp',
                        icon: Icons.add_a_photo_outlined,
                        color: Colors.orange.shade600,
                        onTap: () {
                          // 
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportEmergencyScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      HeroServiceCard(
                        title: 'Nhận nuôi\n& Cứu hộ',
                        icon: Icons.volunteer_activism_outlined,
                        color: const Color(0xFFF43F5E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RescueMapScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Mini Map Placeholder 
                  const Text(
                    'Bản đồ khu vực của bạn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      image: const DecorationImage(
                        // Hình nền lưới giống bản đồ
                        image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                        fit: BoxFit.cover,
                        opacity: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, size: 40, color: const Color(0xFFF43F5E).withOpacity(0.8)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Mở bản đồ lớn'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(140, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Danh sách các ca khẩn cấp gần đây
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cần cứu hộ khẩn cấp',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RescueMapScreen()),
                          );
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFF43F5E))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentReports.length, 
                      itemBuilder: (context, index) {
                        // gọi một widget card riêng cho từng report
                        return SOSItemCard(
                          report: recentReports[index], 
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => RescueMapScreen(
                                initialReport: recentReports[index],
                                ),
                              )
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
