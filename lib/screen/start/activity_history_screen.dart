import 'package:flutter/material.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng DefaultTabController để quản lý state của 2 Tab
    return DefaultTabController(
      length: 2, // Có 2 tab
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Hoạt động', style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130), // Chiều cao cho cụm Thống kê + TabBar
            child: Column(
              children: [
                // 1. Thống kê nhanh
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.volunteer_activism, iconColor: Colors.green.shade600, bgColor: Colors.green.shade50,
                        label: 'Đã cứu', value: '12', unit: 'bé',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.campaign, iconColor: Colors.blue.shade600, bgColor: Colors.blue.shade50,
                        label: 'Báo cáo', value: '5', unit: 'ca',
                      ),
                    ],
                  ),
                ),
                
                // 2. Thanh Tabs 
                TabBar(
                  labelColor: Colors.red.shade500,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: Colors.red.shade500,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Nhiệm vụ cứu hộ'),
                    Tab(text: 'Ca tôi báo cáo'),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // 3. Nội dung cuộn của 2 Tabs
        body: TabBarView(
          children: [
            _buildRescueTasksTab(), 
            _buildMyReportsTab(),   
          ],
        ),
      ),
    );
  }

  // Helper: Dựng thẻ Thống kê
  Widget _buildStatCard({required IconData icon, required Color iconColor, required Color bgColor, required String label, required String value, required String unit}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: iconColor.withOpacity(0.2))),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.1)),
                    const SizedBox(width: 2),
                    Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // TAB 1: Rescuer Flow
  Widget _buildRescueTasksTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card 1: Nhiệm vụ đang thực hiện
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: const Border(left: BorderSide(color: Colors.blue, width: 4)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Stack(
            children: [
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(12))),
                  child: Row(
                    children: [
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue.shade700)),
                      const SizedBox(width: 6),
                      Text('ĐANG ĐI CỨU', style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=200&auto=format&fit=crop', width: 60, height: 60, fit: BoxFit.cover)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chó cỏ - Bị xe đụng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey.shade400), const SizedBox(width: 4), Text('Đường Nguyễn Văn Linh, Q.7', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {}, icon: const Icon(Icons.arrow_forward), label: const Text('Tiếp tục chỉ đường'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: BorderSide(color: Colors.blue.shade200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: Quy trình Tracking Nhận nuôi 4 tuần
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: const Border(left: BorderSide(color: Colors.purple, width: 4)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Row(children: [Icon(Icons.home, size: 12, color: Colors.purple.shade700), const SizedBox(width: 4), Text('ĐANG THEO DÕI', style: TextStyle(color: Colors.purple.shade700, fontSize: 10, fontWeight: FontWeight.bold))]),
                  ),
                  Text('Tuần 2 / 4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple.shade600))
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(radius: 24, backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200&auto=format&fit=crop'), backgroundColor: Colors.grey.shade200),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mèo mướp (Bé Bánh Bao)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Nhận nuôi ngày 15/07', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Thanh tiến độ 4 tuần
              Row(
                children: [
                  _buildProgressDot(isActive: true, isCompleted: true, label: '1'), _buildProgressLine(isActive: true),
                  _buildProgressDot(isActive: true, isCompleted: false, label: '2', isPulsing: true), _buildProgressLine(isActive: false),
                  _buildProgressDot(isActive: false, isCompleted: false, label: '3'), _buildProgressLine(isActive: false),
                  _buildProgressDot(isActive: false, isCompleted: false, label: '4'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Nộp ảnh tuần 2'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade500, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 3: Nhiệm vụ hoàn thành
        Opacity(
          opacity: 0.7,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Row(children: [Icon(Icons.check, size: 12, color: Colors.green.shade700), const SizedBox(width: 4), Text('ĐÃ HOÀN THÀNH', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold))]),
                    ),
                    Text('10/07/2026', style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix([0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0]),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('https://images.unsplash.com/photo-1543852786-1cf6624b9987?q=80&w=200&auto=format&fit=crop', width: 48, height: 48, fit: BoxFit.cover)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chó Poodle đi lạc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                          Text('Bàn giao Trạm cứu hộ Quận 2', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDot({required bool isActive, required bool isCompleted, required String label, bool isPulsing = false}) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: isActive ? Colors.purple.shade500 : Colors.grey.shade300, shape: BoxShape.circle,
        border: isPulsing ? Border.all(color: Colors.purple.shade100, width: 4) : null,
      ),
      child: Center(
        child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgressLine({required bool isActive}) {
    return Expanded(child: Container(height: 2, color: isActive ? Colors.purple.shade500 : Colors.grey.shade300));
  }

  // TAB 2: Reporter Flow
  Widget _buildMyReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card Report 1: Có người đang cứu 
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chó hoang bị thương', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)), child: Text('CÓ RESCUER NHẬN', style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 4),
              Text('Bạn báo cáo 2 giờ trước', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 16),
              
              // Timeline mini
              Container(
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade200, width: 2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineItem(isActive: true, title: 'Rescuer "Trần Văn A" đang tới hiện trường', time: '15 phút trước'),
                    const SizedBox(height: 12),
                    _buildTimelineItem(isActive: false, title: 'Hệ thống ghi nhận ca cứu hộ', time: '2 giờ trước'),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card Report 2: Đang chờ
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mèo kẹt trên mái', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)), child: Text('ĐANG CHỜ', style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 4),
              Text('Bạn báo cáo 5 phút trước', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.wifi_tethering, color: Colors.red.shade500, size: 16),
                    const SizedBox(width: 8),
                    Text('Tín hiệu đang phát bán kính 5km', style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({required bool isActive, required String title, required String time}) {
    return Transform.translate(
      offset: const Offset(-13, 0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10, height: 10, margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: isActive ? Colors.blue.shade500 : Colors.grey.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey.shade600)),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          )
        ],
      ),
    );
  }
}