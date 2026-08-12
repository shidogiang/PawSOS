import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart'; 
import 'package:paw_sos/screen/card/radar_item_card.dart';
import 'active_rescue_screen.dart'; 
class RescueMapScreen extends StatefulWidget {
  final AnimalReportModel? initialReport;
  final bool isMainTab;

  const RescueMapScreen({super.key, this.initialReport, this.isMainTab = false});

  @override
  State<RescueMapScreen> createState() => _RescueMapScreenState();
}

class _RescueMapScreenState extends State<RescueMapScreen> with TickerProviderStateMixin {
  final List<AnimalReportModel> _nearbyReports = AnimalReportModel.getMockData();
  
  // Điều khiển Bản đồ
  final MapController _mapController = MapController();
  final LatLng _defaultLocation = const LatLng(10.762622, 106.660172); // Trung tâm TP.HCM
  
  bool _showDetailPanel = false;
  bool _showRadarPanel = false;
  AnimalReportModel? _selectedReport;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialReport != null) {
      _selectedReport = widget.initialReport;
      _showDetailPanel = true;
    } else {
      _showRadarPanel = !widget.isMainTab;
    }
  }

  void _openDetail(AnimalReportModel report) {
    setState(() {
      _selectedReport = report;
      _showDetailPanel = true;
    });

    // Trượt bản đồ tới vùng nhiễu của ca này
    if (report.noiseLat != null && report.noiseLng != null) {
      _animatedMapMove(LatLng(report.noiseLat!, report.noiseLng!), 15.0);
    }
  }

  void _closeDetail() {
    setState(() {
      _showDetailPanel = false;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && !_showDetailPanel) {
          setState(() => _selectedReport = null);
        }
      });
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  void _handleClaimRescue() async {
    setState(() => _isClaiming = true);
    
    // Mô phỏng call API Update Status lên Supabase
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _isClaiming = false;
        _showDetailPanel = false; 
      });
      
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => ActiveRescueScreen(mission: _selectedReport!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialReport?.noiseLat != null 
                    ? LatLng(widget.initialReport!.noiseLat!, widget.initialReport!.noiseLng!) 
                    : _defaultLocation,
                initialZoom: 13.0,
                // Chặn xoay bản đồ để người dùng đỡ bị chóng mặt
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate), 
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.paw_sos.app',
                ),
                CircleLayer(
                  circles: _buildRadarCircles(),
                ),
              ],
            ),
          ),

          Positioned(
            top: 50, left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!widget.isMainTab) 
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
                  )
                else
                  const SizedBox(width: 40),

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

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            left: 0, right: 0,
            bottom: (_showRadarPanel && !_showDetailPanel) ? 0 : -screenHeight,
            child: _buildRadarPanel(),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            left: 0, right: 0,
            bottom: _showDetailPanel ? 0 : -screenHeight,
            child: _buildDetailPanel(),
          ),

          if (widget.isMainTab && !_showDetailPanel)
            Positioned(
              bottom: 24, right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() => _showRadarPanel = !_showRadarPanel);
                },
                child: Icon(_showRadarPanel ? Icons.map : Icons.format_list_bulleted, color: const Color(0xFFF43F5E)),
              ),
            )
        ],
      ),
    );
  }

  List<CircleMarker> _buildRadarCircles() {
    List<CircleMarker> circles = [];
    
    // Nếu đang xem 1 ca cụ thể -> Vẽ 1 vùng to
    if (_selectedReport != null && _selectedReport!.noiseLat != null) {
      circles.add(CircleMarker(
        point: LatLng(_selectedReport!.noiseLat!, _selectedReport!.noiseLng!),
        color: Colors.red.withOpacity(0.2),
        borderStrokeWidth: 2,
        borderColor: Colors.red.withOpacity(0.5),
        radius: 150, // Bán kính hiển thị trên Map
        useRadiusInMeter: true,
      ));
    } 
    // Nếu chưa chọn ca nào -> Vẽ tất cả vùng nhiễu của các ca mở
    else {
      for (var report in _nearbyReports) {
        if (report.noiseLat != null) {
          circles.add(CircleMarker(
            point: LatLng(report.noiseLat!, report.noiseLng!),
            color: Colors.orange.withOpacity(0.3),
            borderStrokeWidth: 1.5,
            borderColor: Colors.orange.withOpacity(0.6),
            radius: 500, // Bán kính 500m
            useRadiusInMeter: true,
          ));
        }
      }
    }
    return circles;
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