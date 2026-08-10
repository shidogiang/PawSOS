import 'package:flutter/material.dart';
import 'package:paw_sos/model/AnimalReportModel.dart'; 
import 'package:paw_sos/screen/card/radar_item_card.dart';
import 'active_rescue_screen.dart'; 
class RescueMapScreen extends StatefulWidget {
  final AnimalReportModel? initialReport; // Thêm tham số nhận dữ liệu từ màn trước
  final bool isMainTab; // Xác định xem màn hình có đang mở bằng Bottom Navigation Bar không

  const RescueMapScreen({super.key, this.initialReport, this.isMainTab = false});

  @override
  State<RescueMapScreen> createState() => _RescueMapScreenState();
}

class _RescueMapScreenState extends State<RescueMapScreen> {
  final List<AnimalReportModel> _nearbyReports = AnimalReportModel.getMockData();
  
  bool _showDetailPanel = false; // Trạng thái bật/tắt Panel Chi tiết
  bool _showRadarPanel = false; // Trạng thái bật/tắt Panel Radar
  AnimalReportModel? _selectedReport; // Đang xem chi tiết con nào?
  
  bool _isClaiming = false; // Đang call API?

  // initState để kiểm tra ngay khi mở màn hình
  @override
  void initState() {
    super.initState();
    // Nếu màn hình trước  có truyền 1 report vào
    if (widget.initialReport != null) {
      _selectedReport = widget.initialReport;
      _showDetailPanel = true; // Tự động đẩy Panel Xác nhận lên
    } else {
      // Nếu không phải là Tab chính (nghĩa là user bấm nút "Xem tất cả" từ Trang chủ)
      // thì tự động bật Panel Danh sách lên. Còn nếu ở Tab Radar thì giấu đi để xem bản đồ.
      _showRadarPanel = !widget.isMainTab;
    }
  }

  void _openDetail(AnimalReportModel report) {
    setState(() {
      _selectedReport = report;
      _showDetailPanel = true;
    });
  }

  void _closeDetail() {
    setState(() {
      _showDetailPanel = false;
      _selectedReport = null; 
    });
  }

  void _handleClaimRescue() async {
    setState(() => _isClaiming = true);
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isClaiming = false;
        _showDetailPanel = false; // Tự động ẩn Panel Detail
      });
      
      // Hiện thông báo Snack bar 
       Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => ActiveRescueScreen(mission: _selectedReport!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery giúp lấy chiều cao màn hình để làm animation trượt
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          // layer 1 map background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),

          // layer 1.5 Vùng nhiễu trên Map Cho phép chạm trực tiếp
          if (_selectedReport == null) ...[
             // Đang ở chế độ xem chung -> Hiển thị nhiều đốm đỏ
            Positioned(
              top: screenHeight * 0.4, left: MediaQuery.of(context).size.width * 0.2,
              child: GestureDetector(
                onTap: () => _openDetail(_nearbyReports[0]),
                child: _buildNoiseMapCircle(),
              ),
            ),
            if (_nearbyReports.length > 1)
              Positioned(
                top: screenHeight * 0.6, right: MediaQuery.of(context).size.width * 0.2,
                child: GestureDetector(
                  onTap: () => _openDetail(_nearbyReports[1]),
                  child: _buildNoiseMapCircle(),
                ),
              ),
          ] else ...[
            // Đã chọn cụ thể 1 ca -> Vẽ duy nhất 1 điểm trung tâm
            Positioned(
              top: screenHeight * 0.3,
              left: MediaQuery.of(context).size.width * 0.5 - 60, // Căn giữa
              child: _buildNoiseMapCircle(),
            ),
          ],

          // layer 2: app bar
          Positioned(
            top: 50, left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!widget.isMainTab) // Giấu nút Back nếu đang ở Bottom Tab
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
                  )
                else
                  const SizedBox(width: 40), // Placeholder giữ khoảng cách cân bằng

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      Icon(Icons.radar, color: Colors.blue, size: 16), SizedBox(width: 8),
                      Text('Radar Paws SOS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: const Icon(Icons.filter_alt, color: Colors.black87)),
              ],
            ),
          ),

          // layer 3 radar panel (Danh sách gần đây)
          // Dùng AnimatedPositioned để làm hiệu ứng trượt mượt mà
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            left: 0, right: 0,
            bottom: (_showRadarPanel && !_showDetailPanel) ? 0 : -screenHeight, // Bị giấu xuống đáy nếu tắt
            child: _buildRadarPanel(),
          ),

          // layer 4: detail panel (Panel Xác Nhận)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            left: 0, right: 0,
            bottom: _showDetailPanel ? 0 : -screenHeight, // Bật lên từ đáy
            child: _buildDetailPanel(),
          ),

          // layer 5: floating button (Chỉ hiện khi đang ở Tab Radar và chưa bật Panel Detail)
          if (widget.isMainTab && !_showDetailPanel)
            Positioned(
              bottom: 24, right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() => _showRadarPanel = !_showRadarPanel); // Bật tắt Panel
                },
                child: Icon(_showRadarPanel ? Icons.map : Icons.format_list_bulleted, color: const Color(0xFFF43F5E)),
              ),
            )
        ],
      ),
    );
  }


  Widget _buildNoiseMapCircle() {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Center(
        child: Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
          child: const Icon(Icons.pets, color: Colors.white, size: 20),
        ),
      ),
    );
  }


  Widget _buildRadarPanel() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gần bạn nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Quét thấy ${_nearbyReports.length} ca trong bán kính 5km', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.refresh, size: 16), label: const Text('Làm mới'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _nearbyReports.length,
              itemBuilder: (context, index) {
                return RadarItemCard(
                  report: _nearbyReports[index],
                  onTap: () => _openDetail(_nearbyReports[index]), 
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
     if (_selectedReport == null) return const SizedBox.shrink();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.close), onPressed: _closeDetail),
              const Expanded(child: Center(child: SizedBox(width: 40, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))))),
              const SizedBox(width: 48), 
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(6)),
                    child: Text('KHẨN CẤP (${_selectedReport!.status})', style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(_selectedReport!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(_selectedReport!.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87, 
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24)
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock, color: Colors.yellow, size: 14),
                              SizedBox(width: 6),
                              Text('Tọa độ đang bảo mật', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade100), borderRadius: BorderRadius.circular(12)),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
                        children: [
                          TextSpan(text: 'Mô tả từ Reporter: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                          TextSpan(text: _selectedReport!.description),
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade400),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Nhấn Tiếp nhận, hệ thống sẽ mở khóa API RLS và gửi tọa độ GPS chính xác. Không nhận mà bỏ sẽ bị trừ điểm.', style: TextStyle(fontSize: 12, color: Colors.black54))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isClaiming ? null : _handleClaimRescue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500, padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isClaiming ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.favorite, color: Colors.white),
                      label: Text(_isClaiming ? 'Đang gọi Supabase...' : 'TÔI SẼ ĐI CỨU BÉ NÀY!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}